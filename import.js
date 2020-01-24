'use strict'

const _ = require('lodash')
const async = require('async')
const aws = require('aws-sdk')
const camelize = require('camelcase')
const crypto = require('crypto')
const decamelize = require('decamelize')
const fs = require('fs')
const mongo = require('mongodb')
const mysql = require('mysql')
const path = require('path')
const yaml = require('js-yaml')

require.extensions['.sql'] = (module, filename) => {
  module.exports = fs.readFileSync(path.resolve(__dirname, filename), 'utf8')
}

const MYSQL_HOST = process.env.MYSQL_HOST || '127.0.0.1'
const MYSQL_PORT = process.env.MYSQL_PORT || 3306
const MYSQL_USER = process.env.MYSQL_USER
const MYSQL_PASSWORD = process.env.MYSQL_PASSWORD

const MONGODB = process.env.MONGODB || 'mongodb://localhost:27017/'

const AWS_ACCESS_KEY_ID = process.env.AWS_ACCESS_KEY_ID
const AWS_SECRET_ACCESS_KEY = process.env.AWS_SECRET_ACCESS_KEY
const AWS_REGION = process.env.AWS_REGION
const AWS_ACCOUNT_ID = process.env.AWS_ACCOUNT_ID

const formulas = yaml.safeLoad(fs.readFileSync(path.resolve(__dirname, 'formulas.yaml'), 'utf8'))

const log = (s) => {
  console.log((new Date()).toISOString().substr(11).replace('Z', ''), s)
}

const cleanupArrayToStr = (a) => {
  return _.uniq(a.join(' ').split(/"|„|“|\(|\)|<|>|;|,| |\n/).filter((v) => v !== ''))
}

const importProps = (mysqlDb, callback) => {
  log(`start database ${mysqlDb} import`)

  var mongoCon
  var queueUrl
  var sqlCon = mysql.createConnection({
    host: MYSQL_HOST,
    port: MYSQL_PORT,
    user: MYSQL_USER,
    password: MYSQL_PASSWORD,
    database: mysqlDb,
    multipleStatements: true
  })

  aws.config = new aws.Config()
  aws.config.accessKeyId = AWS_ACCESS_KEY_ID
  aws.config.secretAccessKey = AWS_SECRET_ACCESS_KEY
  aws.config.region = AWS_REGION

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
        { key: { size: 1 } },
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

      var limit = 10000
      var count = limit
      var offset = 0

      async.whilst(
        (cb) => { cb(null, count === limit) },
        (callback) => {
          sqlCon.query(require('./sql/get_properties.sql'), [limit, offset], (err, props) => {
            if (err) { return callback(err) }

            count = props.length
            offset = offset + count

            let cleanProps = _.map(props, x => _.pickBy(x, (value, key) => { return value === 0 || value === false || !!value }))
            let correctedProps = _.map(cleanProps, x => {
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
                let fileArray = x.string.split('\n')

                if (fileArray[0].substr(0, 2) === 'A:' && fileArray[0].substr(2)) { _.set(x, 'filename', fileArray[0].substr(2)) }
                if (fileArray[1].substr(0, 2) === 'B:' && fileArray[1].substr(2)) { _.set(x, 'md5', fileArray[1].substr(2)) }
                if (fileArray[2].substr(0, 2) === 'C:' && fileArray[2].substr(2)) { _.set(x, 's3', fileArray[2].substr(2)) }
                if (fileArray[3].substr(0, 2) === 'D:' && fileArray[3].substr(2)) { _.set(x, 'url', fileArray[3].substr(2)) }
                if (fileArray[4].substr(0, 2) === 'E:' && fileArray[4].substr(2)) { _.set(x, 'size', parseInt(fileArray[4].substr(2), 10)) }

                _.unset(x, 'string')
              }
              if (x.type === 'formula' && x.string) {
                let formula = formulas.find(f => f.old === x.string)

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

        var l = entities.length
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

      var sqs = new aws.SQS()
      var lambda = new aws.Lambda()

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

        var l = entities.length
        var sqs = new aws.SQS()

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

  var sqlCon = mysql.createConnection({
    host: MYSQL_HOST,
    port: MYSQL_PORT,
    user: MYSQL_USER,
    password: MYSQL_PASSWORD,
    database: mysqlDb,
    multipleStatements: true
  })

  aws.config = new aws.Config()
  aws.config.accessKeyId = process.env.AWS_ACCESS_KEY_ID
  aws.config.secretAccessKey = process.env.AWS_SECRET_ACCESS_KEY
  aws.config.region = process.env.AWS_REGION

  sqlCon.query(require('./sql/get_files.sql'), (err, files) => {
    if (err) { return callback(err) }

    const s3 = new aws.S3()

    async.eachSeries(files, (file, callback) => {
      if (!file.s3_key) {
        if (file.md5) {
          if (fs.existsSync(path.join(process.env.OLD_FILES_PATH, mysqlDb, file.md5.substr(0, 1), file.md5))) {
            let f = fs.readFileSync(path.join(process.env.OLD_FILES_PATH, mysqlDb, file.md5.substr(0, 1), file.md5))

            if (!fs.existsSync(process.env.FILES_PATH)) {
              fs.mkdirSync(process.env.FILES_PATH)
            }
            if (!fs.existsSync(path.join(process.env.FILES_PATH, mysqlDb))) {
              fs.mkdirSync(path.join(process.env.FILES_PATH, mysqlDb))
            }
            if (!fs.existsSync(path.join(process.env.FILES_PATH, mysqlDb, file.md5.substr(0, 1)))) {
              fs.mkdirSync(path.join(process.env.FILES_PATH, mysqlDb, file.md5.substr(0, 1)))
            }
            fs.writeFileSync(path.join(process.env.FILES_PATH, mysqlDb, file.md5.substr(0, 1), file.md5), f)

            sqlCon.query(require('./sql/update_files.sql'), [file.md5, f.length, 'Copied local file', file.id], (err) => {
              if (err) { return callback(err) }
              return callback(null)
            })
          } else {
            sqlCon.query(require('./sql/update_files_error.sql'), ['No local file', file.id], (err) => {
              if (err) { return callback(err) }
              return callback(null)
            })
          }
        } else {
          sqlCon.query(require('./sql/update_files_error.sql'), ['No file', file.id], (err) => {
            if (err) { return callback(err) }
            return callback(null)
          })
        }
      } else {
        s3.getObject({ Bucket: process.env.AWS_S3_BUCKET, Key: file.s3_key }, (err, data) => {
          if (err) {
            sqlCon.query(require('./sql/update_files_error.sql'), [err.toString(), file.id], callback)
            return
          }

          const md5 = crypto.createHash('md5').update(data.Body).digest('hex')
          const size = data.Body.length

          if (file.md5 && file.md5 !== md5) { log(`${file.id} - md5 not same ${md5}`) }
          if (file.filesize !== size) { log(`${file.id} - size not same ${size}`) }

          if (!fs.existsSync(process.env.FILES_PATH)) {
            fs.mkdirSync(process.env.FILES_PATH)
          }
          if (!fs.existsSync(path.join(process.env.FILES_PATH, mysqlDb))) {
            fs.mkdirSync(path.join(process.env.FILES_PATH, mysqlDb))
          }
          if (!fs.existsSync(path.join(process.env.FILES_PATH, mysqlDb, md5.substr(0, 1)))) {
            fs.mkdirSync(path.join(process.env.FILES_PATH, mysqlDb, md5.substr(0, 1)))
          }
          fs.writeFileSync(path.join(process.env.FILES_PATH, mysqlDb, md5.substr(0, 1), md5), data.Body)

          sqlCon.query(require('./sql/update_files.sql'), [md5, size, 'S3', file.id], callback)
        })
      }
    }, (err) => {
      if (err) { return callback(err) }

      log(`end ${mysqlDb} files import`)
      return callback(null)
    })
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
    // importFiles(row.db, callback)
    importProps(row.db, callback)
  }, (err) => {
    if (err) {
      console.error(err.toString())
      process.exit(1)
    }

    process.exit(0)
  })
})
