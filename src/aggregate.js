// eslint-disable-next-line no-unused-vars
import dotenv from 'dotenv/config'

import { MongoClient } from 'mongodb'
import { getTimeLeft, log, sendAggregateToApi } from './helpers.js'

const mongoClient = new MongoClient(process.env.MONGODB)
const mongoDbList = await mongoClient.db().admin().listDatabases()
const dbList = mongoDbList.databases.filter((db) => !['admin', 'analytics', 'config', 'local'].includes(db.name)).map((db) => db.name)

// const dbList = [
// ]

log(`Databases: ${dbList.join(', ')}`)
console.log('')

for (let i = 0; i < dbList.length; i++) {
  const database = dbList[i]
  log(`${database} - Start`)

  // await aggregateAllEntities(database, { 'private._type.string': { $in: ['company', 'invoice_folder', 'invoice_in', 'invoice_out'] } })
  await aggregateAllEntities(database)

  log(`${database} - End`)
  console.log('')
}

process.exit()

async function aggregateAllEntities (database, filter = {}) {
  log('Aggregate All Entities')

  console.log(filter)

  const mongo = await mongoClient.connect()
  const entities = await mongo.db(database).collection('entity')
    .find(
      filter,
      { projection: { _id: true } }
    )
    .sort({ aggregated: 1 })
    .toArray()

  const start = Date.now() / 1000
  const entityTotal = entities.length
  let entityCount = entities.length

  log(`  ${entityCount} entities to go`)

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]

    await sendAggregateToApi(database, entity._id)

    entityCount--
    if (entityCount % 100 === 0 && entityCount > 0) {
      const end = Date.now() / 1000
      const speed = (entityTotal - entityCount) / (end - start)
      const timeLeft = getTimeLeft(entityCount / speed)

      log(`  ${entityCount} entities (${timeLeft}) to go`)
    }
  }

  await mongoClient.close()
}
