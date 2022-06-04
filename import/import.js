'use strict'

const _ = require('lodash')
const async = require('async')
const aws = require('aws-sdk')
const camelize = require('camelcase')
const crypto = require('crypto')
const decamelize = require('decamelize')
const dotenv = require('dotenv')
const fs = require('fs')
const mongo = require('mongodb')
const mysql = require('mysql')
const path = require('path')
const yaml = require('js-yaml')

dotenv.config()

require.extensions['.sql'] = (module, filename) => {
  module.exports = fs.readFileSync(path.resolve(__dirname, filename), 'utf8')
}

const MYSQL_HOST = process.env.MYSQL_HOST
const MYSQL_PORT = process.env.MYSQL_PORT
const MYSQL_USER = process.env.MYSQL_USER
const MYSQL_PASSWORD = process.env.MYSQL_PASSWORD

const MONGODB = process.env.MONGODB

const S3_ENDPOINT = process.env.S3_ENDPOINT
const S3_KEY = process.env.S3_KEY
const S3_SECRET = process.env.S3_SECRET
const S3_BUCKET = process.env.S3_BUCKET

const DO_ENDPOINT = process.env.DO_ENDPOINT
const DO_KEY = process.env.DO_KEY
const DO_SECRET = process.env.DO_SECRET
const DO_BUCKET = process.env.DO_BUCKET

const formulas = yaml.load(fs.readFileSync(path.resolve(__dirname, 'formulas.yaml'), 'utf8'))

const log = (s) => {
  console.log((new Date()).toISOString().substr(11).replace('Z', ''), s)
}

const cleanupArrayToStr = (a) => {
  return _.uniq(a.join(' ').split(/"|„|“|\(|\)|<|>|;|,| |\n/).filter((v) => v !== ''))
}

const importProps = (mysqlDb, callback) => {
  log(`start database ${mysqlDb} import`)

  let mongoCon
  let queueUrl
  const sqlCon = mysql.createConnection({
    host: MYSQL_HOST,
    port: MYSQL_PORT,
    user: MYSQL_USER,
    password: MYSQL_PASSWORD,
    database: mysqlDb,
    multipleStatements: true
  })

  async.series([
    (callback) => {
      if (mysqlDb === 'repis') { return callback(null) }

      const sqls = [
        'create_props_table.sql',
        'create_entities.sql',
        'create_properties.sql',
        'create_definitions.sql',
        'create_menu.sql',
        'create_conf.sql'
      ]

      async.eachSeries(sqls, (sql, callback) => {
        log('create props table - ' + sql)

        sqlCon.query(require('./sql/' + sql), callback)
      }, callback)
    },

    (callback) => {
      mongo.MongoClient.connect(MONGODB, { ssl: true, sslValidate: true, useNewUrlParser: true, useUnifiedTopology: true }, (err, con) => {
        if (err) { return callback(err) }

        mongoCon = con
        return callback(null)
      })
    },

    (callback) => {
      mongoCon.db(mysqlDb).listCollections({ name: 'entity' }).toArray((err, collections) => {
        if (err) { return callback(err) }

        if (collections.length > 0) {
          mongoCon.db(mysqlDb).dropCollection('entity', callback)
        } else {
          return callback(null)
        }
      })
    },
    (callback) => {
      mongoCon.db(mysqlDb).listCollections({ name: 'property' }).toArray((err, collections) => {
        if (err) { return callback(err) }

        if (collections.length > 0) {
          mongoCon.db(mysqlDb).dropCollection('property', callback)
        } else {
          return callback(null)
        }
      })
    },

    (callback) => {
      log('create entity indexes')
      mongoCon.db(mysqlDb).collection('entity').createIndexes([
        { key: { oid: 1 } },
        { key: { access: 1 } },
        { key: { 'private._type.string': 1 } },
        { key: { 'search.private': 1 } },
        { key: { 'search.public': 1 } },
        { key: { 'private.entu_user.string': 1 } },
        { key: { 'private.entu_api_key.string': 1 } }
      ], callback)
    },
    (callback) => {
      log('create property indexes')
      mongoCon.db(mysqlDb).collection('property').createIndexes([
        { key: { entity: 1 } },
        { key: { type: 1 } },
        { key: { deleted: 1 } },
        { key: { reference: 1 } },
        { key: { filesize: 1 } },
        { key: { 'created.by': 1 } },
        { key: { 'deleted.by': 1 } }
      ], callback)
    },

    (callback) => {
      log('insert entities to mongodb')
      sqlCon.query(require('./sql/get_entities.sql'), (err, entities) => {
        if (err) { return callback(err) }

        mongoCon.db(mysqlDb).collection('entity').insertMany(entities, callback)
      })
    },

    (callback) => {
      log('insert props to mongodb')

      const limit = 10000
      let count = limit
      let offset = 0

      async.whilst(
        (cb) => { cb(null, count === limit) },
        (callback) => {
          sqlCon.query(require('./sql/get_properties.sql'), [limit, offset], (err, props) => {
            if (err) { return callback(err) }

            count = props.length
            offset = offset + count

            const cleanProps = _.map(props, x => _.pickBy(x, (value, key) => { return value === 0 || value === false || !!value }))
            const correctedProps = _.map(cleanProps, x => {
              if (x.type) {
                if (x.type.substr(0, 1) === '_') {
                  _.set(x, 'type', '_' + decamelize(camelize(x.type.substr(1)), '_'))
                } else {
                  _.set(x, 'type', decamelize(camelize(x.type), '_'))
                }
              }
              if (x.created_by) {
                _.set(x, 'created.by', x.created_by)
                _.unset(x, 'created_by')
              }
              if (x.created_at) {
                _.set(x, 'created.at', x.created_at)
                _.unset(x, 'created_at')
              }
              if (x.deleted_by) {
                _.set(x, 'deleted.by', x.deleted_by)
                _.unset(x, 'deleted_by')
              }
              if (x.deleted_at) {
                _.set(x, 'deleted.at', x.deleted_at)
                _.unset(x, 'deleted_at')
              }
              if (x.datatype === 'datetime' || x.datatype === 'atby') {
                _.set(x, 'datetime', x.date)
                _.unset(x, 'date')
              }
              if (x.datatype === 'boolean') {
                _.set(x, 'boolean', x.integer === 1)
                _.unset(x, 'integer')
              }
              if (x.datatype === 'file' && x.string) {
                const fileArray = x.string.split('\n')

                if (fileArray[0].substr(0, 2) === 'A:' && fileArray[0].substr(2)) { _.set(x, 'filename', fileArray[0].substr(2)) }
                if (fileArray[1].substr(0, 2) === 'B:' && fileArray[1].substr(2)) { _.set(x, 'md5', fileArray[1].substr(2)) }
                if (fileArray[2].substr(0, 2) === 'C:' && fileArray[2].substr(2)) { _.set(x, 's3', fileArray[2].substr(2)) }
                if (fileArray[3].substr(0, 2) === 'D:' && fileArray[3].substr(2)) { _.set(x, 'url', fileArray[3].substr(2)) }
                if (fileArray[4].substr(0, 2) === 'E:' && fileArray[4].substr(2)) { _.set(x, 'filesize', parseInt(fileArray[4].substr(2), 10)) }

                _.unset(x, 'string')
              }
              if (x.type === 'formula' && x.string) {
                const formula = formulas.find(f => f.old === x.string)

                if (formula) {
                  x.string = formula.new
                } else {
                  console.log('MISSING FORMULA: ' + x.string)
                }
              }
              if (x.type === 'entu_api_key') {
                x.string = crypto.createHash('sha256').update(x.string).digest('hex')
              }

              _.unset(x, 'datatype')

              return x
            })

            mongoCon.db(mysqlDb).collection('property').insertMany(correctedProps, callback)
          })
        }, callback)
    },

    (callback) => {
      log('close mysql connection')
      sqlCon.end(callback)
    },

    (callback) => {
      log('replace mysql ids with mongodb _ids')

      mongoCon.db(mysqlDb).collection('entity').find({}).sort({ oid: 1 }).toArray((err, entities) => {
        if (err) { return callback(err) }

        let l = entities.length
        async.eachSeries(entities, (entity, callback) => {
          async.parallel([
            (callback) => {
              mongoCon.db(mysqlDb).collection('property').updateMany({ entity: entity.oid }, { $set: { entity: entity._id } }, callback)
            },
            (callback) => {
              mongoCon.db(mysqlDb).collection('property').updateMany({ reference: entity.oid }, { $set: { reference: entity._id } }, callback)
            },
            (callback) => {
              mongoCon.db(mysqlDb).collection('property').updateMany({ 'created.by': entity.oid }, { $set: { 'created.by': entity._id } }, callback)
            },
            (callback) => {
              mongoCon.db(mysqlDb).collection('property').updateMany({ 'deleted.by': entity.oid }, { $set: { 'deleted.by': entity._id } }, callback)
            }
          ], (err) => {
            if (err) { return callback(err) }

            l--
            if (l % 10000 === 0 && l > 0) {
              log(`${l} entities to go`)
            }
            return callback(null)
          })
        }, callback)
      })
    },

    (callback) => {
      log('create sqs queue')

      const sqs = new aws.SQS()
      const lambda = new aws.Lambda()

      sqs.createQueue({
        QueueName: `entu-api-entity-aggregate-queue-${mysqlDb}.fifo`,
        Attributes: {
          VisibilityTimeout: '600',
          FifoQueue: 'true',
          ContentBasedDeduplication: 'true'
        }
      }, function (err, data) {
        if (err) {
          console.error(err.message || err)
          return callback(null)
        }

        queueUrl = data.QueueUrl

        sqs.getQueueAttributes({
          QueueUrl: queueUrl,
          AttributeNames: ['QueueArn']
        }, function (err, data) {
          if (err) {
            console.error(err.message || err)
            return callback(null)
          }

          lambda.createEventSourceMapping({
            EventSourceArn: data.Attributes.QueueArn,
            FunctionName: 'entu-api-entity-aggregate',
            BatchSize: '1'
          }, function (err, data) {
            if (err) {
              console.error(err.message || err)
              return callback(null)
            }

            callback(null)
          })
        })
      })
    },

    (callback) => {
      log('create entities')

      mongoCon.db(mysqlDb).collection('entity').find({}, { _id: true }).sort({ _id: 1 }).toArray((err, entities) => {
        if (err) { return callback(err) }

        const l = entities.length
        const sqs = new aws.SQS()

        async.eachSeries(entities, (entity, callback) => {
          const message = {
            account: mysqlDb,
            entity: entity._id.toString()
          }

          sqs.sendMessage({ QueueUrl: queueUrl, MessageGroupId: mysqlDb, MessageBody: JSON.stringify(message) }, callback)
        }, callback)
      })
    },

    (callback) => {
      log('close mongodb connection')
      mongoCon.close(callback)
    }
  ], (err) => {
    if (err) { return callback(err) }

    log(`end database ${mysqlDb} import\n`)
    return callback(null)
  })
}

const importFiles = (mysqlDb, callback) => {
  log(`start ${mysqlDb} files import`)

  const sqlCon = mysql.createConnection({
    host: MYSQL_HOST,
    port: MYSQL_PORT,
    user: MYSQL_USER,
    password: MYSQL_PASSWORD,
    database: mysqlDb,
    multipleStatements: true
  })

  sqlCon.query(require('./sql/get_files.sql'), (err, files) => {
    if (err) { return callback(err) }

    const s3 = new aws.S3({
      endpoint: new aws.Endpoint(S3_ENDPOINT),
      accessKeyId: S3_KEY,
      secretAccessKey: S3_SECRET
    })

    const d3 = new aws.S3({
      endpoint: new aws.Endpoint(DO_ENDPOINT),
      accessKeyId: DO_KEY,
      secretAccessKey: DO_SECRET
    })

    const d3Folder = mysqlDb.replace('vabamu', 'okupatsioon').replace('hoimurahvad', 'fennougria')

    async.eachSeries(files, (file, callback) => {
      log(`${file.id} - ${file.s3_key} - ${Math.round(file.filesize / 100000000) / 10}GB`)

      s3.getObject({ Bucket: S3_BUCKET, Key: file.s3_key }, (err, s3Data) => {
      // s3.getObject({ Bucket: S3_BUCKET, Key: file.s3_key.replace(mysqlDb + '_2/', mysqlDb + '/') }, (err, s3Data) => {
        if (err) {
          sqlCon.query(require('./sql/update_files_error.sql'), [err.toString(), file.id], callback)
          return
        }

        const s3Md5 = crypto.createHash('md5').update(s3Data.Body).digest('hex')
        const s3Filesize = s3Data.Body.length
        const doKey = `${d3Folder}/${s3Md5.substr(0, 1)}/${s3Md5}`

        log(`${file.id} - ${file.s3_key} - ${Math.round(s3Filesize / 100000000) / 10}GB downloaded`)

        if (file.md5 && file.md5 !== s3Md5) {
          log(`${file.id} - Db/S3 md5 error ${file.md5} vs ${s3Md5}`)
          callback()
          return
        }
        if (file.filesize !== s3Filesize) {
          log(`${file.id} - Db/S3 size error ${file.filesize} vs ${s3Filesize}`)
          callback()
          return
        }

        d3.getObject({ Bucket: DO_BUCKET, Key: doKey }, (err, doData) => {
          if (err && err.code !== 'NoSuchKey') {
            console.log(err)
            sqlCon.query(require('./sql/update_files_error.sql'), [err.toString(), file.id], callback)
            return
          }

          if (err && err.code === 'NoSuchKey') {
            d3.upload({
              ACL: 'private',
              ContentType: s3Data.ContentType,
              Bucket: DO_BUCKET,
              Key: doKey,
              Body: s3Data.Body
            }, (err, doData) => {
              if (err) {
                console.log(err)
                sqlCon.query(require('./sql/update_files_error.sql'), [err.toString(), file.id], callback)
                return
              }

              log(`${file.id} - File uploaded to ${doKey}`)
              callback()
            })
          } else {
            const doMd5 = crypto.createHash('md5').update(doData.Body).digest('hex')
            const doFilesize = doData.Body.length

            if (s3Md5 !== doMd5) { log(`${file.id} - S3/DO md5 error ${s3Md5} vs ${doMd5}`) }
            if (s3Filesize !== doFilesize) { log(`${file.id} - S3/DO size error ${s3Filesize} vs ${doFilesize}`) }

            if (s3Md5 === doMd5 && s3Filesize === doFilesize) {
              sqlCon.query(require('./sql/update_files.sql'), [doMd5, doFilesize, 'DO', file.id], callback)
            } else {
              callback()
            }
          }
        })
      })
    }, (err) => {
      if (err) { return callback(err) }

      log(`end ${mysqlDb} files import`)
      return callback(null)
    })
  })
}

const importFilesS3 = async (mysqlDb, callback) => {
  log(`start ${mysqlDb} files import`)

  const sqlCon = mysql.createConnection({
    host: MYSQL_HOST,
    port: MYSQL_PORT,
    user: MYSQL_USER,
    password: MYSQL_PASSWORD,
    database: mysqlDb
  })

  const s3 = new aws.S3({
    endpoint: new aws.Endpoint(S3_ENDPOINT),
    accessKeyId: S3_KEY,
    secretAccessKey: S3_SECRET
  })

  const prefix = mysqlDb.replace('vabamu', 'okupatsioon').replace('hoimurahvad', 'fennougria')
  let s3Files = []
  let moreResults = true
  let NextContinuationToken

  while (moreResults) {
    const d3Response = await s3.listObjectsV2({ Bucket: S3_BUCKET, Prefix: prefix, ContinuationToken: NextContinuationToken }).promise()

    moreResults = d3Response.IsTruncated
    NextContinuationToken = d3Response.NextContinuationToken

    s3Files = [...s3Files, ...d3Response.Contents]
  }

  console.log(s3Files.length)

  async.eachSeries(s3Files, (file, callback) => {
    sqlCon.query(require('./sql/update_s3.sql'), [
      file.Key,
      file.LastModified,
      file.ETag.replace('"', '').replace('"', ''),
      file.Size,
      file.StorageClass
    ], callback)
  }, (err) => {
    if (err) { return callback(err) }

    log(`end ${mysqlDb} files import`)
    return callback(null)
  })
}

const importFilesDO = async (mysqlDb, callback) => {
  log(`start ${mysqlDb} files import`)

  const sqlCon = mysql.createConnection({
    host: MYSQL_HOST,
    port: MYSQL_PORT,
    user: MYSQL_USER,
    password: MYSQL_PASSWORD,
    database: mysqlDb
  })

  const d3 = new aws.S3({
    endpoint: new aws.Endpoint(DO_ENDPOINT),
    accessKeyId: DO_KEY,
    secretAccessKey: DO_SECRET
  })

  const prefix = mysqlDb.replace('vabamu', 'okupatsioon').replace('hoimurahvad', 'fennougria')
  let s3Files = []
  let moreResults = true
  let NextContinuationToken

  while (moreResults) {
    const d3Response = await d3.listObjectsV2({ Bucket: S3_BUCKET, Prefix: prefix, ContinuationToken: NextContinuationToken }).promise()

    moreResults = d3Response.IsTruncated
    NextContinuationToken = d3Response.NextContinuationToken

    s3Files = [...s3Files, ...d3Response.Contents]
  }

  console.log(s3Files.length)

  async.eachSeries(s3Files, (file, callback) => {
    sqlCon.query(require('./sql/update_do.sql'), [
      file.Key,
      file.LastModified,
      file.ETag.replace('"', '').replace('"', ''),
      file.Size,
      file.StorageClass
    ], callback)
  }, (err) => {
    if (err) { return callback(err) }

    log(`end ${mysqlDb} files import`)
    return callback(null)
  })
}

const connection = mysql.createConnection({
  host: MYSQL_HOST,
  port: MYSQL_PORT,
  user: MYSQL_USER,
  password: MYSQL_PASSWORD
})

connection.query(require('./sql/get_databases.sql'), (err, rows) => {
  if (err) {
    console.error(err.toString())
    process.exit(1)
  }

  connection.end()

  async.eachSeries(rows, (row, callback) => {
    importFilesS3(row.db, callback)
    // importFilesDO(row.db, callback)
    // importFiles(row.db, callback)
    // importProps(row.db, callback)
  }, (err) => {
    if (err) {
      console.error(err.toString())
      process.exit(1)
    }

    process.exit(0)
  })
})
