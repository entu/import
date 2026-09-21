import dotenv from 'dotenv/config'

import { MongoClient } from 'mongodb'
import { log } from './helpers.js'

const mongoClient = new MongoClient(process.env.MONGODB)
const mongoDbList = await mongoClient.db().admin().listDatabases()
let dbList = []

dbList = mongoDbList.databases
  .filter((db) => !['admin', 'analytics', 'config', 'entu', 'local'].includes(db.name))
  .map((db) => db.name)

// dbList = [
//   'roots'
// ]

log(`Databases: ${dbList.join(', ')}`)
console.log('')

for (let i = 0; i < dbList.length; i++) {
  const database = dbList[i]
  log(`${database} - Start`)

  await setIndexes(database)

  log(`${database} - End`)
  console.log('')
}

process.exit()

async function setIndexes (database) {
  log('Setting indexes')

  const mongo = await mongoClient.connect()
  const newDb = mongo.db(database)

  // Define desired indexes for each collection
  const indexSpecs = {
    entity: [
      { key: { 'private._parent.reference': 1 } },
      { key: { 'private._reference.reference': 1 } },
      { key: { 'private._type.string': 1 } },
      { key: { 'private.add_from.reference': 1 } },
      { key: { 'private.entu_api_key.string': 1 } },
      { key: { 'private.entu_passkey.passkey_id': 1 } },
      { key: { 'private.entu_user.invite': 1 } },
      { key: { 'private.entu_user.string': 1 } },
      { key: { 'private.entu_user.uid': 1, 'private.entu_user.provider': 1 } },
      { key: { 'private.formula.string': 1 }, sparse: true },
      { key: { 'private.name.string': 1 } },
      { key: { 'search.domain': 1 } },
      { key: { 'search.private': 1 } },
      { key: { 'search.public': 1 } },
      { key: { access: 1 } },
      { key: { queued: 1 }, sparse: true }
    ],
    property: [
      { key: { 'created.by': 1 } },
      { key: { 'deleted.by': 1 } },
      { key: { deleted: 1 } },
      { key: { entity: 1, type: 1, deleted: 1 } },
      { key: { filesize: 1 } },
      { key: { reference: 1, deleted: 1 } },
      { key: { type: 1, deleted: 1, number: -1 } }
    ],
    stats: [
      { key: { date: 1, function: 1 }, unique: true }
    ]
  }

  // Helper to generate index name from key
  const getIndexName = (key) => {
    return Object.keys(key).map((k) => `${k}_${key[k]}`).join('_')
  }

  // Drop unwanted indexes from each collection
  for (const [collectionName, specs] of Object.entries(indexSpecs)) {
    const collection = newDb.collection(collectionName)
    const existingIndexes = await collection.indexes()
    const desiredNames = specs.map((spec) => getIndexName(spec.key))

    for (const index of existingIndexes) {
      // Skip _id index (can't be dropped) and desired indexes
      if (index.name !== '_id_' && !desiredNames.includes(index.name)) {
        await collection.dropIndex(index.name)
        log(`  Dropped index: ${collectionName}.${index.name}`)
      }
    }
  }

  // Create desired indexes
  await Promise.all([
    newDb.collection('entity').createIndexes(indexSpecs.entity),
    newDb.collection('property').createIndexes(indexSpecs.property),
    newDb.collection('stats').createIndexes(indexSpecs.stats)
  ])
}
