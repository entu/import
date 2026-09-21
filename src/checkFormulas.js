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

  await checkFormulas(database)
}

console.log('')
process.exit()

async function checkFormulas (database) {
  const mongo = await mongoClient.connect()

  const entities = await mongo.db(database).collection('entity')
    .find(
      { 'private.formula': { $exists: true } },
      { projection: { _id: true, 'private.formula': true } }
    )
    .sort({ _id: 1 })
    .toArray()

  for (const entity of entities) {
    const formulas = entity.private?.formula || []

    for (const f of formulas) {
      if (f.string === undefined || f.string === null) continue

      console.log(`${database};${entity._id};${f.string}`)
    }
  }
}
