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

  await checkAggregation(database)
}

console.log('')
process.exit()

async function checkAggregation (database) {
  const mongo = await mongoClient.connect()
  const collection = mongo.db(database).collection('entity')

  const [result] = await collection.aggregate([
    {
      $group: {
        _id: null,
        total: { $sum: 1 },
        queued: { $sum: { $cond: [{ $ifNull: ['$queued', false] }, 1, 0] } }
      }
    }
  ]).toArray()

  if (!result) {
    log(`${database} - no entities`)
    return
  }

  const { total, queued } = result

  if (queued === 0) return

  const done = total - queued
  const progress = total > 0 ? ((done / total) * 100).toFixed(1) : '100.0'

  log(`${database} - ${progress}% (${done}/${total} done, ${queued} queued)`)
}
