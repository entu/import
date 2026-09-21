import dotenv from 'dotenv/config'

import { MongoClient } from 'mongodb'
import { log, sendAggregateToApi } from './helpers.js'

// Fields that describe a property but are not its value. Everything else on a
// property document is considered a value field (string/number/reference/... as
// well as custom ones like entu_user's uid/email/provider).
const systemKeys = ['_id', 'entity', 'type', 'language', 'created', 'deleted']

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

  await removeDuplicateProps(database)

  log(`${database} - End`)
  console.log('')
}

process.exit()

async function removeDuplicateProps (database) {
  const mongo = await mongoClient.connect()
  const collection = mongo.db(database).collection('property')

  const affectedEntityIds = new Set()

  // Find groups of active properties with duplicate (entity, type, value).
  // Group on every non-system field so a duplicate is an exact value match.
  // This also covers properties with custom value fields (e.g. entu_user's
  // uid/email/provider), not just the standard string/number/reference/etc.
  const duplicates = await collection.aggregate([
    {
      $match: {
        // Skip file properties - identical filenames are not duplicate values
        filename: { $exists: false },
        filesize: { $exists: false },
        deleted: { $exists: false }
      }
    },
    {
      $group: {
        _id: {
          entity: '$entity',
          type: '$type',
          language: '$language',
          value: {
            $arrayToObject: {
              $filter: {
                input: { $objectToArray: '$$ROOT' },
                cond: { $not: [{ $in: ['$$this.k', systemKeys] }] }
              }
            }
          }
        },
        ids: { $push: '$_id' },
        count: { $sum: 1 }
      }
    },
    {
      $match: { count: { $gt: 1 } }
    }
  ]).toArray()

  log(`  Found ${duplicates.length} duplicate group(s)`)

  let totalDeleted = 0

  duplicates.sort((a, b) => `${a._id.type}.${a._id.language ?? ''}`.localeCompare(`${b._id.type}.${b._id.language ?? ''}`))

  for (const group of duplicates) {
    const { entity, language, type, value } = group._id
    // Keep the newest (_id is ObjectId, so sort ascending = oldest first)
    const idsToDelete = group.ids
      .sort((a, b) => a.toString().localeCompare(b.toString()))
      .slice(0, -1) // drop last (newest), soft-delete the rest

    await collection.updateMany(
      { _id: { $in: idsToDelete } },
      { $set: { deleted: { at: new Date() } } }
    )

    affectedEntityIds.add(entity.toString())
    const typeLabel = language ? `${type}.${language}` : type

    log(`  ${entity} ${idsToDelete.length} ${typeLabel} ${JSON.stringify(value)}`)
    totalDeleted += idsToDelete.length
  }

  // Find active properties with no value: either no value fields at all (only
  // system fields left) or a single 'string' field that is empty when trimmed.
  const empties = await collection.aggregate([
    {
      $match: {
        filename: { $exists: false },
        filesize: { $exists: false },
        deleted: { $exists: false }
      }
    },
    {
      $addFields: {
        valueFields: {
          $filter: {
            input: { $objectToArray: '$$ROOT' },
            cond: { $not: [{ $in: ['$$this.k', systemKeys] }] }
          }
        }
      }
    },
    {
      $match: {
        $expr: {
          $or: [
            { $eq: [{ $size: '$valueFields' }, 0] },
            {
              $and: [
                { $eq: [{ $size: '$valueFields' }, 1] },
                { $eq: [{ $arrayElemAt: ['$valueFields.k', 0] }, 'string'] },
                { $eq: [{ $trim: { input: { $cond: [{ $eq: [{ $type: '$string' }, 'string'] }, '$string', ''] } } }, ''] }
              ]
            }
          ]
        }
      }
    },
    { $project: { _id: true, entity: true, type: true } }
  ]).toArray()

  log(`  Found ${empties.length} empty property(ies)`)

  empties.sort((a, b) => a.type.localeCompare(b.type))

  for (const property of empties) {
    await collection.updateOne(
      { _id: property._id },
      { $set: { deleted: { at: new Date() } } }
    )

    affectedEntityIds.add(property.entity.toString())
    log(`  ${property.entity} empty ${property.type}`)
  }

  log(`  Affected entity(ies): ${affectedEntityIds.size}`)

  for (const entityId of affectedEntityIds) {
    await sendAggregateToApi(database, entityId)
  }
}
