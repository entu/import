import dotenv from 'dotenv'
import fs from 'fs'
import path from 'path'
import https from 'https'
import crypto from 'crypto'
import { MongoClient } from 'mongodb'
import mysql from 'mysql2/promise'
import _ from 'lodash'
import yaml from 'js-yaml'
import camelize from 'camelcase'
import decamelize from 'decamelize'

dotenv.config()

const formulas = yaml.load(fs.readFileSync(path.resolve(path.dirname(''), 'import', 'formulas.yaml'), 'utf8'))
const mongoClient = new MongoClient(process.env.MONGODB, { useNewUrlParser: true, useUnifiedTopology: true })

importEntities()

async function importEntities () {
  const dbList = await executeSql('get_databases')

  for (let i = 0; i < dbList.length; i++) {
    const { db: database } = dbList[i]
    log(`Start database ${database} import`)

    await prepareMySql(database)
    await prepareMongoDb(database)
    await insertEntities(database)
    await insertProperties(database)
    await replaceIds(database)
    await aggregateEntities(database)

    log(`End database ${database} import`)
  }

  process.exit()
}

async function prepareMySql (database) {
  const sqls = [
    'create_props_table',
    'create_entities',
    'create_properties',
    'create_definitions',
    'create_menu',
    'create_conf'
  ]

  for (let i = 0; i < sqls.length; i++) {
    log(`Run ${sqls[i]}.sql in MySQL`)
    await executeSql(sqls[i], database)
  }
}

async function prepareMongoDb (database) {
  const mongo = await mongoClient.connect()
  const entityTables = await mongo.db(database).listCollections({ name: 'entity' }).toArray()
  const propertyTables = await mongo.db(database).listCollections({ name: 'property' }).toArray()

  if (entityTables.length > 0) {
    await mongo.db(database).dropCollection('entity')
    log('Deleted entity collection from MongoDB')
  }
  if (propertyTables.length > 0) {
    await mongo.db(database).dropCollection('property')
    log('Deleted property collection from MongoDB')
  }

  log('Add entity indexes to MongoDB')
  await mongo.db(database).collection('entity').createIndexes([
    { key: { oid: 1 } },
    { key: { access: 1 } },
    { key: { 'private._type.string': 1 } },
    { key: { 'search.private': 1 } },
    { key: { 'search.public': 1 } },
    { key: { 'private.entu_user.string': 1 } },
    { key: { 'private.entu_api_key.string': 1 } }
  ])

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

  await mongoClient.close()
}

async function insertEntities (database) {
  log('Insert entities to MongoDB')
  const mongo = await mongoClient.connect()
  const entities = await executeSql('get_entities', database)

  await mongo.db(database).collection('entity').insertMany(entities)
  await mongoClient.close()
}

async function insertProperties (database) {
  log('Insert properties to MongoDB')

  const limit = 10000
  let count = limit
  let offset = 0

  while (count === limit) {
    const mongo = await mongoClient.connect()
    const properties = await executeSql('get_properties', database, [limit, offset])

    const cleanProperties = properties.map(cleanProperty)

    await mongo.db(database).collection('property').insertMany(cleanProperties)
    await mongoClient.close()

    count = properties.length
    offset = offset + count
  }
}

async function replaceIds (database) {
  log('Replace MySQL id with MongoDB _id')

  const mongo = await mongoClient.connect()

  const entities = await mongo.db(database).collection('entity').find({}).sort({ oid: 1 }).toArray()
  let entityCount = entities.length

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]

    await mongo.db(database).collection('property').updateMany({ entity: entity.oid }, { $set: { entity: entity._id } })
    await mongo.db(database).collection('property').updateMany({ reference: entity.oid }, { $set: { reference: entity._id } })
    await mongo.db(database).collection('property').updateMany({ 'created.by': entity.oid }, { $set: { 'created.by': entity._id } })
    await mongo.db(database).collection('property').updateMany({ 'deleted.by': entity.oid }, { $set: { 'deleted.by': entity._id } })

    entityCount--
    if (entityCount % 100 === 0 && entityCount > 0) {
      log(`  ${entityCount} entities to go`)
    }
  }

  await mongoClient.close()
}

async function aggregateEntities (database) {
  log('Aggregate Entities')

  const mongo = await mongoClient.connect()

  const entities = await mongo.db(database).collection('entity').find({}).sort({ oid: 1 }).toArray()
  let entityCount = entities.length

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]

    await sendAggregateToApi(database, entity._id)

    entityCount--
    if (entityCount % 100 === 0 && entityCount > 0) {
      log(`  ${entityCount} entities to go`)
    }
  }

  await mongoClient.close()
}

async function executeSql (filename, database, params) {
  const sqlPath = path.resolve(path.dirname(''), 'sql', filename + '.sql')
  const sql = fs.readFileSync(sqlPath, 'utf8')

  const connection = await mysql.createConnection({
    host: process.env.MYSQL_HOST,
    port: process.env.MYSQL_PORT,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database,
    multipleStatements: true
  })

  const [rows] = await connection.query(sql, params)

  connection.end()

  return rows
}

function cleanProperty (property) {
  const newProperty = {}

  Object.keys(property).forEach(key => {
    if (property[key] === 0 || property[key] === false || !!property[key]) {
      newProperty[key] = property[key]
    }
  })

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

  _.unset(newProperty, 'datatype')

  return newProperty
}

const sendAggregateToApi = async (database, entityId) => {
  return new Promise((resolve, reject) => {
    https.get(`${process.env.ENTU_API_URL}/entity/${entityId}/aggregate?account=${database}`, response => {
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
