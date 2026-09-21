import dotenv from 'dotenv/config'

import { MongoClient ,ObjectId } from 'mongodb'
import { getTimeLeft, log, sendAggregateToApi } from './helpers.js'

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

  // await aggregateAllEntities(database)
  // await aggregateAllEntities(database, { 'private._type.string': { $in: ['person'] } })
  await aggregateAllEntities(database, { _id: { $in: [
    '506e7c33dcb4b5c4fde735d0',
    '66d9bdb8f8faac14d800acbf'
  ].map((x) => new ObjectId(x)) } })

  log(`${database} - End`)
  console.log('')
}

process.exit()

async function aggregateAllEntities (database, filter = {}) {
  log('Aggregate All Entities')

  console.log(filter)

  const mongo = await mongoClient.connect()

  // Get entities from entity collection
  const entitiesFromEntityCollection = await mongo.db(database).collection('entity')
    .find(
      filter,
      { projection: { _id: true } }
    )
    .sort({ aggregated: 1 })
    .toArray()

  // Get distinct entity IDs from property collection
  // const entitiesFromPropertyCollection = await mongo.db(database).collection('property').distinct('entity', { deleted: { $exists: false } })

  // Merge and deduplicate entity IDs
  const entityIdSet = new Set()

  for (const e of entitiesFromEntityCollection) {
    entityIdSet.add(e._id.toString())
  }
  // entitiesFromPropertyCollection.forEach((id) => entityIdSet.add(id.toString()))

  const entityIds = Array.from(entityIdSet)

  const start = Date.now() / 1000
  const entityTotal = entityIds.length
  let entityCount = entityIds.length

  log(`  ${entityCount} entities to go`)

  for (let i = 0; i < entityIds.length; i++) {
    const entityId = entityIds[i]

    await sendAggregateToApi(database, entityId)

    entityCount--
    if (entityCount % 100 === 0 && entityCount > 0) {
      const end = Date.now() / 1000
      const speed = (entityTotal - entityCount) / (end - start)
      const timeLeft = getTimeLeft(entityCount / speed)

      log(`  ${entityCount} entities (${timeLeft}) to go`)
    }
  }
}
