import dotenv from 'dotenv'
import fs from 'fs'
import path from 'path'
import https from 'https'
import crypto from 'crypto'
import { MongoClient, ObjectId } from 'mongodb'
import mysql from 'mysql2/promise'
import _ from 'lodash'
import yaml from 'js-yaml'
import camelize from 'camelcase'
import decamelize from 'decamelize'
import mime from 'mime-types'
import { S3Client, GetObjectCommand } from '@aws-sdk/client-s3'
import { Upload } from '@aws-sdk/lib-storage'

dotenv.config()

const formulas = yaml.load(fs.readFileSync(path.resolve(path.dirname(''), 'import', 'formulas.yaml'), 'utf8'))
const mongoClient = new MongoClient(process.env.MONGODB)
const mysqlConnections = {}

importEntities()

async function importEntities () {
  const databases = await executeSql('get_databases')

  log(`Databases: ${dbList.join(', ')}`)
  console.log('')
  console.log('')

  for (let i = 0; i < dbList.length; i++) {
    const database = dbList[i]
    log(`Start database ${database} import`)

    await prepareMySql(database)
    await prepareMongoDb(database)
    await insertEntities(database)
    await insertProperties(database)
    await cleanupMySql(database)
    await replaceIds(database)
    await copyFiles(database)
    await aggregateNewEntities(database)
    await aggregateAllEntities(database)

    log(`End database ${database} import`)
    console.log('')
    console.log('')
  }

  process.exit()
}

async function prepareMySql (database) {
  log('Run create_mongo_tables.sql in MySQL')
  await executeSql('create_mongo_tables', database)

  log('Run create_entities.sql in MySQL')
  await executeSql('create_entities', database)

  log('Run create_properties.sql in MySQL')
  await executeSql('create_properties', database)

  log('Run create_menu.sql in MySQL')
  await executeSql('create_menu', database, [
    database,
    database,
    database
  ])

  log('Run create_definitions.sql in MySQL')
  await executeSql('create_definitions', database, [
    database
  ])

  log('Run create_conf.sql in MySQL')
  await executeSql('create_conf', database, [
    database,
    database
  ])

  log('Run create_database_entity.sql in MySQL')
  await executeSql('create_database_entity', database, [
    database,
    database,
    '^-?[0-9]+$',
    database
  ])
}

async function prepareMongoDb (database) {
  const mongo = await mongoClient.connect()

  const entityTables = await mongo.db(database).listCollections({ name: 'entity' }).toArray()
  if (entityTables.length > 0) {
    await mongo.db(database).dropCollection('entity')
    log('Deleted entity collection from MongoDB')
  }

  const propertyTables = await mongo.db(database).listCollections({ name: 'property' }).toArray()
  if (propertyTables.length > 0) {
    await mongo.db(database).dropCollection('property')
    log('Deleted property collection from MongoDB')
  }

  const statsTables = await mongo.db(database).listCollections({ name: 'stats' }).toArray()
  if (statsTables.length > 0) {
    await mongo.db(database).dropCollection('stats')
    log('Deleted stats collection from MongoDB')
  }

  log('Add entity indexes to MongoDB')
  await mongo.db(database).collection('entity').createIndexes([
    { key: { oid: 1 } },
    { key: { access: 1 } },
    { key: { 'private._parent.reference': 1 } },
    { key: { 'private._type.string': 1 } },
    { key: { 'private.add_from.reference': 1 } },
    { key: { 'private.entu_api_key.string': 1 } },
    { key: { 'private.entu_user.string': 1 } },
    { key: { 'private.name.string': 1 } },
    { key: { 'search.private': 1 } },
    { key: { 'search.public': 1 } }
  ])

  log('Add entity search index to MongoDB')
  await mongo.db(database).collection('entity').createIndex({
    'search.private': 'text'
  }, {
    name: 'search'
  })

  log('Add property indexes to MongoDB')
  await mongo.db(database).collection('property').createIndexes([
    { key: { entity: 1 } },
    { key: { type: 1 } },
    { key: { deleted: 1 } },
    { key: { reference: 1 } },
    { key: { filesize: 1 } },
    { key: { 'created.by': 1 } },
    { key: { 'deleted.by': 1 } }
  ])

  log('Add stats indexes to MongoDB')
  await mongo.db(database).collection('stats').createIndex(
    { date: 1, function: 1 },
    { unique: true }
  )

  await mongoClient.close()
}

async function insertEntities (database) {
  log('Insert entities to MongoDB')
  const mongo = await mongoClient.connect()
  const entities = await executeSql('get_entities', database)
  const cleanEntities = entities.map(x => ({
    _id: x.created_at ? new ObjectId(x.created_at.getTime() / 1000) : undefined,
    oid: x.oid
  }))

  await mongo.db(database).collection('entity').insertMany(cleanEntities)
  await mongoClient.close()
}

async function insertProperties (database) {
  log('Insert properties to MongoDB')

  const propertiesCountResult = await executeSql('get_properties_count', database)
  const propertiesCount = propertiesCountResult[0].count

  const limit = 10000
  let count = limit
  let offset = 0

  while (count === limit) {
    const mongo = await mongoClient.connect()
    const properties = await executeSql('get_properties', database, [limit])

    const cleanProperties = properties.map(cleanProperty)

    await Promise.all([
      mongo.db(database).collection('property').insertMany(cleanProperties),
      executeSql('update_property', database, [properties.map(x => x.id)])
    ])

    count = properties.length
    offset = offset + count

    log(`  ${propertiesCount - offset} properties to go`)
  }

  await mongoClient.close()
}

async function cleanupMySql (database) {
  log('Run drop_mongo_tables.sql in MySQL')
  await executeSql('drop_mongo_tables', database)
}

async function replaceIds (database) {
  log('Replace MySQL id with MongoDB _id')

  const mongo = await mongoClient.connect()

  const entities = await mongo.db(database).collection('entity').find({
    oid: { $exists: true },
    propsOk: { $exists: false }
  }, {
    collation: {
      locale: 'et',
      numericOrdering: true
    }
  }).sort({ oid: 1 }).toArray()

  const start = Date.now() / 1000
  const entityTotal = entities.length
  let entityCount = entities.length

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]

    await Promise.all([
      mongo.db(database).collection('property').updateMany({ entity: entity.oid }, { $set: { entity: entity._id } }),
      mongo.db(database).collection('property').updateMany({ reference: entity.oid }, { $set: { reference: entity._id } }),
      mongo.db(database).collection('property').updateMany({ 'created.by': entity.oid }, { $set: { 'created.by': entity._id } }),
      mongo.db(database).collection('property').updateMany({ 'deleted.by': entity.oid }, { $set: { 'deleted.by': entity._id } }),
      mongo.db(database).collection('entity').updateOne({ _id: entity._id }, { $set: { propsOk: true } })
    ])

    entityCount--
    if (entityCount % 1000 === 0 && entityCount > 0) {
      const end = Date.now() / 1000
      const speed = (entityTotal - entityCount) / (end - start)
      const timeLeft = getTimeLeft(entityCount / speed)

      log(`  ${entityCount} entities (${timeLeft}) to go`)
    }
  }

  await mongoClient.close()
}

async function copyFiles (database) {
  log('Copy files to DO Spaces')

  const mongo = await mongoClient.connect()

  const properties = await mongo.db(database).collection('property').find({ s3: { $exists: true }, filename: { $exists: true } }).sort({ entity: 1, _id: 1 }).toArray()

  const s3Client = new S3Client({
    endpoint: process.env.S3_ENDPOINT,
    credentials: {
      accessKeyId: process.env.S3_KEY,
      secretAccessKey: process.env.S3_SECRET
    }
  })

  const spacesClient = new S3Client({
    endpoint: process.env.DO_ENDPOINT,
    credentials: {
      accessKeyId: process.env.DO_KEY,
      secretAccessKey: process.env.DO_SECRET
    }
  })

  const start = Date.now() / 1000
  const filesTotal = properties.length
  let filesCount = properties.length

  for (let i = 0; i < properties.length; i++) {
    const { _id, entity, filename, s3 } = properties[i]

    const getCommand = new GetObjectCommand({
      Bucket: process.env.S3_BUCKET,
      Key: s3
    })

    let s3item

    try {
      s3item = await s3Client.send(getCommand)
    } catch (error) {

    }

    if (s3item) {
      try {
        const upload = new Upload({
          client: spacesClient,
          params: {
            Bucket: process.env.DO_BUCKET,
            Key: `${database}/${entity}/${_id}`,
            ContentDisposition: `inline;filename="${encodeURI(filename.replace('"', '\"'))}"`,
            ContentType: mime.lookup(filename) || 'application/octet-stream',
            Body: s3item.Body
          }
        })

        await upload.done()
        await mongo.db(database).collection('property').updateOne({ _id }, { $unset: { s3: '' } })
      } catch (error) {
        log(`  ${error.code} - ${s3} - ${filename}`)
      }
    } else {
      log(`  Not found - ${s3} - ${filename}`)
    }

    filesCount--
    if (filesCount % 100 === 0 && filesCount > 0) {
      const end = Date.now() / 1000
      const speed = (filesTotal - filesCount) / (end - start)
      const timeLeft = getTimeLeft(filesCount / speed)

      log(`  ${filesCount} files (${timeLeft}) to go`)
    }
  }

  await mongoClient.close()
}

async function aggregateNewEntities (database) {
  log('Aggregate New Entities')

  const mongo = await mongoClient.connect()

  const entities = await mongo.db(database).collection('entity').find({ aggregated: { $exists: false } }).sort({ _id: 1 }).toArray()

  const start = Date.now() / 1000
  const entityTotal = entities.length
  let entityCount = entities.length

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]

    await sendAggregateToApi(database, entity._id)

    entityCount--
    if (entityCount % 1000 === 0 && entityCount > 0) {
      const end = Date.now() / 1000
      const speed = (entityTotal - entityCount) / (end - start)
      const timeLeft = getTimeLeft(entityCount / speed)

      log(`  ${entityCount} entities (${timeLeft}) to go`)
    }
  }

  await mongoClient.close()
}

async function aggregateAllEntities (database) {
  log('Aggregate All Entities')

  const mongo = await mongoClient.connect()

  const entities = await mongo.db(database).collection('entity').find().sort({ _id: 1 }).toArray()

  const start = Date.now() / 1000
  const entityTotal = entities.length
  let entityCount = entities.length

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]

    await sendAggregateToApi(database, entity._id)

    entityCount--
    if (entityCount % 1000 === 0 && entityCount > 0) {
      const end = Date.now() / 1000
      const speed = (entityTotal - entityCount) / (end - start)
      const timeLeft = getTimeLeft(entityCount / speed)

      log(`  ${entityCount} entities (${timeLeft}) to go`)
    }
  }

  await mongoClient.close()
}

async function mysqlDb (database) {
  if (!mysqlConnections[database]) {
    mysqlConnections[database] = await mysql.createConnection({
      host: process.env.MYSQL_HOST,
      port: process.env.MYSQL_PORT,
      user: process.env.MYSQL_USER,
      password: process.env.MYSQL_PASSWORD,
      database,
      multipleStatements: true
    })
  }

  return mysqlConnections[database]
}

async function executeSql (filename, database, params) {
  const sqlPath = path.resolve(path.dirname(''), 'sql', filename + '.sql')
  const sql = fs.readFileSync(sqlPath, 'utf8')

  const connection = await mysqlDb(database)
  const [rows] = await connection.query(sql, params)

  return rows
}

function cleanProperty (property) {
  const newProperty = {}

  Object.keys(property).forEach(key => {
    if (property[key] === 0 || property[key] === false || !!property[key]) {
      newProperty[key] = property[key]
    }
  })

  if (newProperty.created_at) {
    _.set(newProperty, '_id', new ObjectId(newProperty.created_at.getTime() / 1000))
  }

  if (newProperty.type) {
    if (newProperty.type.substr(0, 1) === '_') {
      _.set(newProperty, 'type', '_' + decamelize(camelize(newProperty.type.substr(1)), '_'))
    } else {
      _.set(newProperty, 'type', decamelize(camelize(newProperty.type), '_'))
    }
  }

  if (newProperty.created_by) {
    _.set(newProperty, 'created.by', newProperty.created_by)
    _.unset(newProperty, 'created_by')
  }

  if (newProperty.created_at) {
    _.set(newProperty, 'created.at', newProperty.created_at)
    _.unset(newProperty, 'created_at')
  }

  if (newProperty.deleted_by) {
    _.set(newProperty, 'deleted.by', newProperty.deleted_by)
    _.unset(newProperty, 'deleted_by')
  }

  if (newProperty.deleted_at) {
    _.set(newProperty, 'deleted.at', newProperty.deleted_at)
    _.unset(newProperty, 'deleted_at')
  }

  if (newProperty.datatype === 'datetime' || newProperty.datatype === 'atby') {
    _.set(newProperty, 'datetime', newProperty.date)
    _.unset(newProperty, 'date')
  }

  if (newProperty.datatype === 'integer') {
    _.set(newProperty, 'number', _.toInteger(newProperty.integer))
    _.unset(newProperty, 'integer')
  }

  if (newProperty.datatype === 'decimal') {
    _.set(newProperty, 'number', _.toNumber(newProperty.decimal))
    _.unset(newProperty, 'decimal')
  }

  if (newProperty.datatype === 'boolean') {
    _.set(newProperty, 'boolean', newProperty.integer === 1)
    _.unset(newProperty, 'integer')
  }

  if (newProperty.datatype === 'file' && newProperty.string) {
    const fileArray = newProperty.string.split('\n')

    if (fileArray[0].substr(0, 2) === 'A:' && fileArray[0].substr(2)) { _.set(newProperty, 'filename', fileArray[0].substr(2)) }
    if (fileArray[1].substr(0, 2) === 'B:' && fileArray[1].substr(2)) { _.set(newProperty, 'md5', fileArray[1].substr(2)) }
    if (fileArray[2].substr(0, 2) === 'C:' && fileArray[2].substr(2)) { _.set(newProperty, 's3', fileArray[2].substr(2)) }
    if (fileArray[3].substr(0, 2) === 'D:' && fileArray[3].substr(2)) { _.set(newProperty, 'url', fileArray[3].substr(2)) }
    if (fileArray[4].substr(0, 2) === 'E:' && fileArray[4].substr(2)) { _.set(newProperty, 'filesize', parseInt(fileArray[4].substr(2), 10)) }

    _.unset(newProperty, 'string')
  }

  if (newProperty.type === 'formula' && newProperty.string) {
    const formula = formulas.find(f => f.old === newProperty.string)

    if (formula) {
      newProperty.string = formula.new
    } else {
      log('MISSING FORMULA: ' + newProperty.string)
    }
  }

  if (newProperty.type === 'entu_api_key') {
    newProperty.string = crypto.createHash('sha256').update(newProperty.string).digest('hex')
  }

  _.unset(newProperty, 'id')
  _.unset(newProperty, 'datatype')

  return newProperty
}

const sendAggregateToApi = async (database, entityId) => {
  return new Promise((resolve, reject) => {
    https.get(`${process.env.ENTU_API_URL}/${database}/entity/${entityId}/aggregate`, response => {
      let body = ''

      response.on('data', function (d) {
        body += d
      })

      response.on('end', function () {
        try {
          resolve(JSON.parse(body))
        } catch (e) {
          console.error(e)
          reject(new Error(e))
        }
      })
    })
  })
}

function log (message) {
  console.log(new Date().toISOString().substring(11).replace('Z', ''), message)
}

function getTimeLeft (seconds) {
  // return hours and minutes
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds - (hours * 3600)) / 60)

  if (hours === 0) {
    return `${minutes}m`
  }

  return `${hours}h ${minutes}m`
}
