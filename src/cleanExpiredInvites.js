import dotenv from 'dotenv/config'

import { MongoClient } from 'mongodb'
import { log, sendAggregateToApi } from './helpers.js'

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

  await cleanExpiredInvites(database)

  log(`${database} - End`)
  console.log('')
}

process.exit()

async function cleanExpiredInvites (database) {
  const mongo = await mongoClient.connect()

  const query = {
    type: 'entu_user',
    invite: { $exists: true },
    deleted: { $exists: false },
    'created.at': { $lt: new Date(Date.now() - 24 * 60 * 60 * 1000) }
  }

  const properties = await mongo.db(database).collection('property')
    .find(query, { projection: { _id: true, entity: true } })
    .toArray()

  if (properties.length === 0) {
    log('  No expired invites found')
    return
  }

  await mongo.db(database).collection('property').updateMany(query, {
    $set: { deleted: { at: new Date(), by: 'entu' } }
  })

  log(`  ${properties.length} expired invites deleted`)

  const entityIds = [...new Set(properties.map((p) => p.entity.toString()))]

  for (const entityId of entityIds) {
    await sendAggregateToApi(database, entityId)
    log(`  Aggregated entity ${entityId}`)
  }
}
