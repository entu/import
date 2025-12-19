// eslint-disable-next-line no-unused-vars
import dotenv from 'dotenv/config'

import { MongoClient, ObjectId } from 'mongodb'
import { getTimeLeft, log, sendAggregateToApi } from './src/helpers.js'

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

  await setOwner(database, '526965e0fa1127480b24affc')
  await addInheritRights(database)
  await removeInheritedRights(database)
  await removeDuplicateRights(database)
  await addBackOwnerRights(database)
  await updateEntities(database)
  await addParent(database, { 'private._type.string': { $in: ['audiovideo', 'book'] } }, '69086bb60de0722edfebce2a')
  await addNewPluginType(database, 'entity-delete-webhook')

  log(`${database} - End`)
  console.log('')
}

process.exit()

async function addInheritRights (database) {
  log('Add Inherit Rights to Entities')

  const mongo = await mongoClient.connect()

  const entities = await mongo.db(database).collection('entity')
    .find(
      { 'private._inheritrights': { $exists: false } },
      { projection: { _id: true } }
    )
    .sort({ _id: 1 })
    .toArray()

  const start = Date.now() / 1000
  const entityTotal = entities.length
  let entityCount = entities.length

  log(`  ${entityCount} entities to go`)

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]

    const existing = await mongo.db(database).collection('property')
      .findOne({
        entity: entity._id,
        type: '_inheritrights',
        deleted: { $exists: false }
      }, { projection: { _id: true } })

    if (!existing) {
      await mongo.db(database).collection('property')
        .insertOne({
          entity: entity._id,
          type: '_inheritrights',
          boolean: true,
          created: { at: new Date() }
        })
    }

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

async function removeInheritedRights (database) {
  log('Remove Inherited Rights')

  const mongo = await mongoClient.connect()

  const entities = await mongo.db(database).collection('entity')
    .find(
      { 'private._inheritrights': { $exists: true } },
      {
        projection: {
          _id: true,
          'private._viewer.reference': true,
          'private._expander.reference': true,
          'private._editor.reference': true,
          'private._owner.reference': true,
          'private._parent_viewer.reference': true,
          'private._parent_expander.reference': true,
          'private._parent_editor.reference': true,
          'private._parent_owner.reference': true
        }
      }
    )
    .sort({ aggregated: 1 })
    .toArray()

  const start = Date.now() / 1000
  const entityTotal = entities.length
  let entityCount = entities.length

  log(`  ${entityCount} entities to go`)

  const types = [
    '_viewer',
    '_expander',
    '_editor',
    '_owner'
  ]

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]

    for (let t = 0; t < types.length; t++) {
      const type = types[t]
      const rights = entity.private[type]?.map((x) => x.reference.toString()) || []
      const parentRights = entity.private[`_parent${type}`]?.map((x) => x.reference.toString()) || []

      // Remove inherited rights
      for (let r = 0; r < rights.length; r++) {
        const reference = rights[r]

        if (parentRights.includes(reference)) {
          await mongo.db(database).collection('property').updateMany({
            entity: entity._id,
            type,
            reference: new ObjectId(reference),
            deleted: { $exists: false }
          }, {
            $set: {
              deleted: { at: new Date() }
            }
          })
        }
      }
    }

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

async function removeDuplicateRights (database) {
  log('Remove Duplicate Rights')

  const mongo = await mongoClient.connect()

  const entities = await mongo.db(database).collection('entity')
    .find(
      {},
      {
        projection: {
          _id: true,
          'private._viewer.reference': true,
          'private._expander.reference': true,
          'private._editor.reference': true,
          'private._owner.reference': true
        }
      }
    )
    .sort({ aggregated: 1 })
    .toArray()

  const start = Date.now() / 1000
  const entityTotal = entities.length
  let entityCount = entities.length

  log(`  ${entityCount} entities to go`)

  const types = [
    '_viewer',
    '_expander',
    '_editor',
    '_owner'
  ]

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]
    let hasChanges = false

    // Build set of references that exist in higher priority types
    const higherPriorityRefs = new Set()

    for (const type of types) {
      const rights = entity.private[type]?.map((x) => x.reference.toString()) || []
      const seen = new Set()

      for (const reference of rights) {
        // Check if this reference exists in a higher priority type
        if (higherPriorityRefs.has(reference)) {
          // Delete from current lower priority type
          await mongo.db(database).collection('property').updateMany({
            entity: entity._id,
            type,
            reference: new ObjectId(reference),
            deleted: { $exists: false }
          }, {
            $set: { deleted: { at: new Date() } }
          })
          hasChanges = true
          continue // Skip adding to seen since we're deleting it
        }

        // Check for duplicates within the same type
        if (seen.has(reference)) {
          // Find all properties with this reference
          const properties = await mongo.db(database).collection('property')
            .find({
              entity: entity._id,
              type,
              reference: new ObjectId(reference),
              deleted: { $exists: false }
            })
            .sort({ _id: 1 })
            .toArray()

          // Delete all but the first
          if (properties.length > 1) {
            await mongo.db(database).collection('property').updateMany({
              _id: { $in: properties.slice(1).map((p) => p._id) }
            }, {
              $set: { deleted: { at: new Date() } }
            })
            hasChanges = true
          }
        }
        else {
          // First time seeing this reference in current type, add it to seen
          seen.add(reference)
        }
      }

      // Add all references from this type to higher priority set for next iterations
      for (const ref of seen) {
        higherPriorityRefs.add(ref)
      }
    }

    if (hasChanges) {
      await sendAggregateToApi(database, entity._id)
    }

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

async function addBackOwnerRights (database) {
  log('Add Back Owner Rights')

  const mongo = await mongoClient.connect()

  // Find all deleted _owner properties that were deleted after 2024-01-01
  const deletedOwners = await mongo.db(database).collection('property')
    .find({
      type: '_owner',
      'deleted.at': { $gt: new Date('2024-01-01') },
      'deleted.by': { $exists: false }
    })
    .toArray()

  // Group by entity to process each entity once
  const entitiesByRef = new Map()
  for (const prop of deletedOwners) {
    const entityId = prop.entity.toString()
    if (!entitiesByRef.has(entityId)) {
      entitiesByRef.set(entityId, [])
    }
    entitiesByRef.get(entityId).push(prop.reference)
  }

  const start = Date.now() / 1000
  const entityTotal = entitiesByRef.size
  let entityCount = entitiesByRef.size

  log(`  ${entityCount} entities to go`)

  for (const [entityIdStr, references] of entitiesByRef) {
    const entityId = new ObjectId(entityIdStr)

    // Get unique references for this entity
    const uniqueRefs = [...new Set(references.map((ref) => ref.toString()))]

    for (const refStr of uniqueRefs) {
      const reference = new ObjectId(refStr)

      // Check if this reference already exists as non-deleted
      const existing = await mongo.db(database).collection('property')
        .findOne({
          entity: entityId,
          type: '_owner',
          reference,
          deleted: { $exists: false }
        })

      if (!existing) {
        // Find the first created (oldest) deleted property for this entity+reference
        const oldestDeleted = await mongo.db(database).collection('property')
          .find({
            entity: entityId,
            type: '_owner',
            reference,
            'deleted.at': { $gt: new Date('2024-01-01') },
            'deleted.by': { $exists: false }
          })
          .sort({ _id: 1 })
          .limit(1)
          .toArray()

        if (oldestDeleted.length > 0) {
          // Remove deleted flag from only the first created property
          await mongo.db(database).collection('property').updateOne({
            _id: oldestDeleted[0]._id
          }, {
            $unset: { deleted: '' }
          })
        }
      }
    }

    await sendAggregateToApi(database, entityId)

    entityCount--
    if (entityCount % 100 === 0 && entityCount > 0) {
      const end = Date.now() / 1000
      const speed = (entityTotal - entityCount) / (end - start)
      const timeLeft = getTimeLeft(entityCount / speed)

      log(`  ${entityCount} entities (${timeLeft}) to go`)
    }
  }

  // Count entities without _owner using aggregation
  const entitiesWithoutOwner = await mongo.db(database).collection('property')
    .aggregate([
      // Get all entities
      { $group: { _id: '$entity' } },
      // Lookup for _owner properties
      {
        $lookup: {
          from: 'property',
          let: { entityId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ['$entity', '$$entityId'] },
                type: '_owner',
                deleted: { $exists: false }
              }
            }
          ],
          as: 'owners'
        }
      },
      // Filter entities with no owners
      { $match: { owners: { $size: 0 } } },
      // Count them
      { $count: 'count' }
    ])
    .toArray()

  const countWithoutOwner = entitiesWithoutOwner.length > 0 ? entitiesWithoutOwner[0].count : 0
  log(`Entities without _owner: ${countWithoutOwner}`)

  await mongoClient.close()
}

async function setOwner (database, ownerId) {
  const mongo = await mongoClient.connect()

  const ownerEntity = await mongo.db(database).collection('entity')
    .findOne({
      _id: new ObjectId(ownerId)
    }, {
      projection: { _id: true }
    })

  if (!ownerEntity._id) {
    log(`No ${ownerId} entity found`)
    return
  }

  log(`Add ${ownerEntity._id} as owner`)

  const entities = await mongo.db(database).collection('entity')
    .find({
      'private._owner.reference': { $ne: ownerEntity._id },
      'private._type.string': { $nin: ['database', 'entity', 'property', 'menu', 'plugin'] }
    }, { projection: { _id: true } })
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
      // Mark other _owner, _editor, _expander, _viewer properties with this ownerId as deleted
      await mongo.db(database).collection('property').updateMany({
        entity: entity._id,
        type: { $in: ['_owner', '_editor', '_expander', '_viewer'] },
        reference: ownerEntity._id,
        deleted: { $exists: false }
      }, {
        $set: { deleted: { at: new Date() } }
      })

      await mongo.db(database).collection('property').insertOne({
        entity: entity._id,
        type: '_owner',
        reference: ownerEntity._id,
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

  await mongoClient.close()
}

async function updateEntities (database) {
  log('Update Entities')

  const mongo = await mongoClient.connect()

  const entities = await mongo.db(database).collection('entity')
    .find({
      // access: { $ne: new ObjectId('4f1defdf9ec6b30b7d3c20fe') },
      // 'private.system.boolean': true,
      'private.name.string': 'type',
      'private._parent.string': 'plugin'

      // 'private._parent.string': 'property',
      // 'private.name.string': 'type',
      // 'private._type.string': {
      // $in: [
      //     //     //     'entity'
      //     //     //     // 'property'
      //     //     //     // 'copy'
      //     //     //     // 'audiovideo',
      //     //     //     // 'book',
      //     //     //     // 'methodical',
      //     //     //     // 'periodical',
      //     //     //     // 'textbook',
      //     //     //     // 'workbook'
      //     'property'
      //   ]
      // }
      // 'private.m2_rks6_nad': { $exists: true }
    }, {
      projection: {
        _id: true,
        'private.set': true
      }
    })
    .sort({ _id: -1 })
    .toArray()

  for (const entity of entities) {
    const _id = entity._id
    const setOk = entity.private?.set?.some((x) => ['entity-add-webhook', 'entity-edit-webhook'].includes(x.string))

    if (!entity.private?.set?.some((x) => x.string === 'entity-add-webhook')) {
      await mongo.db(database).collection('property').insertOne({
        entity: _id,
        type: 'set',
        string: 'entity-add-webhook'
      })
      console.log(`Added entity-add-webhook to ${_id}`)
    }

    if (!entity.private?.set?.some((x) => x.string === 'entity-edit-webhook')) {
      await mongo.db(database).collection('property').insertOne({
        entity: _id,
        type: 'set',
        string: 'entity-edit-webhook'
      })
      console.log(`Added entity-edit-webhook to ${_id}`)
    }

    // if (set !== 'public') continue

    console.log(`${database};${_id};${setOk}`)

    // await mongo.db(database).collection('property').insertOne({
    //   entity: _id,
    //   type: '_deleted',
    //   datetime: new Date()
    // })

    // const pp = await mongo.db(database).collection('property').deleteOne({ _id: set, entity: _id })
    // console.log(`${_parent}.${name}`, pp.deletedCount)

    await sendAggregateToApi(database, _id)
  }

  return

  const start = Date.now() / 1000
  const entityTotal = entities.length
  let entityCount = entities.length

  log(`  ${entityCount} entities to go`)

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]

    const parentNames = await mongo.db(database).collection('property')
      .find({
        entity: { $in: entity.private?._parent?.map((x) => x.reference) },
        type: 'name'
      }, {
        projection: { _id: true, string: true }
      })
      .toArray()

    const names = entity.private?.name || []
    const namesToDelete = names.filter((x) => {
      return parentNames.some((y) => {
        const parentName = y.string
        const nameToCompare = x.string

        if (!parentName || !nameToCompare) return false

        // Check for direct match
        if (parentName === nameToCompare) return true

        // Check if parent name starts with number followed by underscore
        // and the rest matches the name
        const match = parentName.match(/^(\d+)_(.+)$/)
        if (match && match[2] === nameToCompare) return true

        return false
      })
    })

    if (names.length < 1) continue
    // if (namesWithoutParent.length < 1) continue
    if (namesToDelete.length < 1) continue

    console.log(entity._id)
    console.log(parentNames)
    console.log(names)

    for (let n = 0; n < namesToDelete.length; n++) {
      const property = namesToDelete[n]

      console.log(property)

      await mongo.db(database).collection('property').updateOne({
        _id: property._id
      }, {
        $set: {
          deleted: { at: new Date() }
        }
      })
    }

    console.log('')

    // const props = await mongo.db(database).collection('entity').find({
    //   'private._type.string': 'property',
    //   'private._parent.reference': entity._id
    // }).toArray()

    // const propsIds = props.map(x => x._id)

    // await mongo.db(database).collection('property').updateMany({
    //   entity: entity._id,
    //   type: 'm2_rks6_nad'
    // }, {
    //   $set: {
    //     type: 'm2rks6nad'
    //   }
    // })

    // await mongo.db(database).collection('property').insertOne({
    //   entity: entity._id,
    //   // type: '_viewer',
    //   type: '_owner',
    //   reference: new ObjectId('4f1defdf9ec6b30b7d3c20fe'),
    //   created: { at: new Date() }
    // })

    // await mongo.db(database).collection('property').insertOne({
    //   entity: entity._id,
    //   type: '_sharing',
    //   string: 'public',
    //   created: { at: new Date() }
    // })

    // for (let p = 0; p < props.length; p++) {
    //   const prop = props[p]
    //   console.log(entity.private?.name?.at(0)?.string, prop.private?.name?.at(0)?.string)

    //   await mongo.db(database).collection('property').updateMany({
    //     entity: prop._id,
    //     type: '_sharing'
    //   }, {
    //     $set: {
    //       deleted: { at: new Date() }
    //     }
    //   })

    //   await mongo.db(database).collection('property').insertOne({
    //     entity: prop._id,
    //     type: '_sharing',
    //     string: 'public',
    //     created: { at: new Date() }
    //   })

    //   await sendAggregateToApi(database, prop._id)
    // }

    // await mongo.db(database).collection('property').insertOne({
    //   entity: entity._id,
    //   type: '_inheritrights',
    //   boolean: true,
    //   created: { at: new Date() }
    // })

    // await mongo.db(database).collection('property').updateMany({
    //   '_private.parent.reference': entity._id,
    //   type: 'name'
    // }, {
    //   $set: {
    //     type: 'title'
    //   }
    // })

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

async function addNewPluginType (database, pluginType) {
  if (!pluginType) return

  log(`Adding new plugin type ${pluginType}`)

  const mongo = await mongoClient.connect()

  const entities = await mongo.db(database).collection('entity')
    .find({
      'private.name.string': 'type',
      'private._parent.string': 'plugin',
      'private.set.string': { $ne: pluginType }
    }, {
      projection: {
        _id: true,
        'private.set': true
      }
    })
    .sort({ _id: -1 })
    .toArray()

  for (const entity of entities) {
    await mongo.db(database).collection('property').insertOne({
      entity: entity._id,
      type: 'set',
      string: pluginType
    })

    log(`Added ${pluginType} to ${entity._id}`)

    await sendAggregateToApi(database, entity._id)
  }

  await mongoClient.close()
}

async function addParent (database, filter = {}, parentId) {
  log('Add Parent to Entities')

  console.log(filter)

  const mongo = await mongoClient.connect()
  const entities = await mongo.db(database).collection('entity')
    .find(
      { ...filter, 'private._parent.reference': { $ne: new ObjectId(parentId) } },
      { projection: { _id: true } }
    )
    .sort({ _id: 1 })
    .toArray()

  const start = Date.now() / 1000
  const entityTotal = entities.length
  let entityCount = entities.length

  log(`  ${entityCount} entities to go`)

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]

    await mongo.db(database).collection('property').insertOne({
      entity: entity._id,
      type: '_parent',
      reference: new ObjectId(parentId),
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
  }

  await mongoClient.close()
}
