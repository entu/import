// eslint-disable-next-line no-unused-vars
import dotenv from 'dotenv/config'

import { MongoClient } from 'mongodb'
import { getTimeLeft, log, sendAggregateToApi } from './helpers.js'

const mongoClient = new MongoClient(process.env.MONGODB)
const mongoDbList = await mongoClient.db().admin().listDatabases()
const dbList = mongoDbList.databases.filter((db) => !['admin', 'analytics', 'config', 'local'].includes(db.name)).map((db) => db.name)

// const dbList = [
// ]

const dbOwners = process.env.DB_OWNERS?.split(',').map((x) => x.trim()) || []

log(`Databases: ${dbList.join(', ')}`)
console.log('')

log(`Owners: ${dbOwners.join(', ')}`)
console.log('')

for (let i = 0; i < dbList.length; i++) {
  const database = dbList[i]
  log(`${database} - Start`)

  await setDatabaseAsOwner(database)

  log(`${database} - End`)
  console.log('')
}

process.exit()

async function setDatabaseAsOwner (database) {
  const mongo = await mongoClient.connect()

  const dbEntity = await mongo.db(database).collection('entity')
    .findOne({
      'private._type.string': 'database'
    }, {
      projection: { _id: true, 'private.entu_user': true }
    })

  if (!dbEntity?._id) {
    log('No database entity found')
    return
  }

  for (const owner of dbOwners) {
    if (!dbEntity.private?.entu_user?.some((x) => x.string === owner)) {
      await mongo.db(database).collection('property').insertOne({
        entity: dbEntity._id,
        type: 'entu_user',
        string: owner,
        created: { at: new Date() }
      })
    }
  }

  await sendAggregateToApi(database, dbEntity._id)

  log(`Add ${dbEntity._id} as owner`)

  const entities = await mongo.db(database).collection('entity')
    .find({ access: { $ne: dbEntity._id } }, { projection: { _id: true } })
    .sort({ _id: -1 })
    .toArray()

  const start = Date.now() / 1000
  const entityTotal = entities.length
  let entityCount = entities.length

  log(`  ${entityCount} entities to go`)

  const batchSize = 100
  for (let i = 0; i < entities.length; i += batchSize) {
    const batch = entities.slice(i, i + batchSize)

    // Process the batch in parallel
    await Promise.all(batch.map(async (entity) => {
      await mongo.db(database).collection('property').insertOne({
        entity: entity._id,
        type: '_owner',
        reference: dbEntity._id,
        created: { at: new Date() }
      })

      await sendAggregateToApi(database, entity._id)

      entityCount--
      if (entityCount % 100 === 0 && entityCount > 0) {
        const end = Date.now() / 1000
        const speed = (entityTotal - entityCount) / (end - start)
        const timeLeft = getTimeLeft(entityCount / speed)

        log(`  ${entityCount} entities (${timeLeft}) to go`)
      }
    }))
  }

  return `${hours}h ${minutes}m`
}
