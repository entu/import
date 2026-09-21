import dotenv from 'dotenv/config'

import { MongoClient } from 'mongodb'
import { log, sendAggregateToApi } from './helpers.js'

// Configuration
const ENTITY_TYPES = ['entity', 'menu', 'plugin']

const mongoClient = new MongoClient(process.env.MONGODB)
const mongoDbList = await mongoClient.db().admin().listDatabases()
let dbList = []

dbList = mongoDbList.databases
  .filter((db) => !['admin', 'analytics', 'config', 'entu', 'local'].includes(db.name))
  .map((db) => db.name)

// dbList = [
//   'roots'
// ]

const mongo = await mongoClient.connect()

log(`Entity types: ${ENTITY_TYPES.join(', ')}`)
log(`Databases: ${dbList.join(', ')}`)
console.log('')

for (let i = 0; i < dbList.length; i++) {
  const database = dbList[i]
  log(`${database} - Start`)

  await setDatabaseAsParent(database)

  log(`${database} - End`)
  console.log('')
}

process.exit()

// Adds the database entity as _parent to every entity type, menu and plugin that does not have it yet
async function setDatabaseAsParent (database) {
  const db = mongo.db(database)

  const dbEntity = await db.collection('entity').findOne(
    { 'private._type.string': 'database' },
    { projection: { _id: true } }
  )

  if (!dbEntity) {
    log('  Database entity not found')
    return
  }

  log(`  Database entity: ${dbEntity._id}`)

  // Get entities whose aggregated _parent does not include the database entity
  const entities = await db.collection('entity')
    .find(
      {
        'private._type.string': { $in: ENTITY_TYPES },
        'private._parent.reference': { $ne: dbEntity._id }
      },
      {
        projection: { _id: true, 'private._type.string': true, 'private.name.string': true }
      }
    )
    .toArray()

  log(`  Entities without database parent: ${entities.length}`)

  for (const entity of entities) {
    const type = entity.private?._type?.at(0)?.string
    const name = entity.private?.name?.at(0)?.string

    // Check the property itself, the aggregated entity may be stale
    const hasParent = await db.collection('property').findOne({
      entity: entity._id,
      type: '_parent',
      reference: dbEntity._id,
      deleted: { $exists: false }
    })

    if (hasParent) {
      log(`  Re-aggregating ${type} "${name}" (${entity._id}) - _parent already set`)
    }
    else {
      await db.collection('property').insertOne({
        entity: entity._id,
        type: '_parent',
        reference: dbEntity._id,
        created: {
          at: new Date()
        }
      })

      log(`  Added database as parent to ${type} "${name}" (${entity._id})`)
    }

    await sendAggregateToApi(database, entity._id)
  }
}
