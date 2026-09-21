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

  await checkStringType(database)

  log(`${database} - End`)
  console.log('')
}

process.exit()

async function checkStringType (database) {
  const mongo = await mongoClient.connect()
  const collection = mongo.db(database).collection('property')

  // Count active properties by (type, BSON type of string). Used to see, per
  // property type, whether the 'string' field is always the same BSON type or
  // mixed (some proper strings, some not).
  const counts = await collection.aggregate([
    {
      $match: {
        string: { $exists: true },
        deleted: { $exists: false }
      }
    },
    {
      $group: {
        _id: { type: '$type', stringType: { $type: '$string' } },
        count: { $sum: 1 }
      }
    }
  ]).toArray()

  // Group the counts by property type.
  const byType = new Map()
  for (const { _id, count } of counts) {
    if (!byType.has(_id.type)) {
      byType.set(_id.type, [])
    }
    byType.get(_id.type).push({ stringType: _id.stringType, count })
  }

  // Keep only types that have at least one non-string value.
  const affected = [...byType.entries()]
    .filter(([, breakdown]) => breakdown.some((b) => b.stringType !== 'string'))
    .sort((a, b) => a[0].localeCompare(b[0]))

  log(`  Found ${affected.length} type(s) with non-string values`)

  for (const [type, breakdown] of affected) {
    breakdown.sort((a, b) => a.stringType.localeCompare(b.stringType))
    const summary = breakdown.map((b) => `${b.stringType}: ${b.count}`).join(', ')
    log(`  ${type} - ${summary}`)
  }
}
