import dotenv from 'dotenv/config'

import { MongoClient } from 'mongodb'
import { log, sendAggregateToApi } from './helpers.js'

// Configuration
const TEMPLATE_DB = 'template'
const ENTITY_TYPE = 'share_out'
// const ENTITY_TYPE = 'entity'
// const ENTITY_TYPE = 'property'
// const ENTITY_TYPE = 'menu'
// const ENTITY_TYPE = 'plugin'
const OVERWRITE_CHILDREN = true

// Reference property type → entity type it must point to; all other references are not copied
const REFERENCE_TYPES = { add_from: 'menu', plugin: 'plugin' }

// Template entity _id → destination entity _id, reset for every database
const referenceCache = new Map()

const mongoClient = new MongoClient(process.env.MONGODB, { monitorCommands: true })

mongoClient.on('commandStarted', (event) => {
  if (['find'].includes(event.commandName)) return

  log(`[mongo] ${event.databaseName} ${event.commandName} ${JSON.stringify(event.command, null, 2)}`)
})

const mongoDbList = await mongoClient.db().admin().listDatabases()
let dbList = []

dbList = mongoDbList.databases
  .filter((db) => !['admin', 'analytics', 'config', 'entu', 'local'].includes(db.name))
  .map((db) => db.name)

// dbList = [
//   'roots'
// ]

log(`Entity type: ${ENTITY_TYPE}`)
log(`Overwrite children: ${OVERWRITE_CHILDREN}`)
log(`Databases: ${dbList.join(', ')}`)
console.log('')

for (let i = 0; i < dbList.length; i++) {
  const database = dbList[i]
  log(`${database} - Start`)

  await copyEntityDefinition(database, ENTITY_TYPE, OVERWRITE_CHILDREN)

  log(`${database} - End`)
  console.log('')
}

process.exit()

async function copyEntityDefinition (database, entityType, overwrite) {
  const mongo = await mongoClient.connect()
  const templateDb = mongo.db(TEMPLATE_DB)
  const destDb = mongo.db(database)

  referenceCache.clear()

  // Get template entity with given type
  const templateEntity = await templateDb.collection('entity').findOne(
    {
      'private._type.string': 'entity',
      'private.name.string': entityType
    },
    {
      projection: { _id: true }
    }
  )

  if (!templateEntity) {
    log('  Template entity not found')
    return
  }

  log(`  Template entity found: ${templateEntity._id}`)

  // Find destination entity with same name
  let destEntity = await destDb.collection('entity').findOne(
    {
      'private._type.string': 'entity',
      'private.name.string': entityType
    },
    {
      projection: { _id: true }
    }
  )

  if (!destEntity) {
    log('  Destination entity not found - creating new one')

    // Create empty entity document (all data comes from properties)
    const result = await destDb.collection('entity').insertOne({})

    destEntity = { _id: result.insertedId }
    log(`  New entity created: ${destEntity._id}`)
  }
  else {
    log(`  Destination entity found: ${destEntity._id}`)
  }

  // Copy properties from template to destination entity
  const newProperties = await copyPropertiesFromTemplate(
    templateDb,
    destDb,
    database,
    templateEntity._id,
    destEntity._id,
    'entity'
  )

  newProperties.push(...await getDatabaseParentProperties(destDb, destEntity._id))

  if (newProperties.length > 0) {
    await destDb.collection('property').insertMany(newProperties)
    log(`  Properties updated: ${newProperties.length}`)
  }

  // Aggregate the updated entity
  await sendAggregateToApi(database, destEntity._id)

  // Get template entity children
  const templateChildren = await templateDb.collection('entity')
    .find(
      {
        'private._type.string': 'property',
        'private._parent.reference': templateEntity._id
      },
      {
        projection: { _id: true, 'private.name': true }
      }
    )
    .toArray()

  log(`  Template children: ${templateChildren.length}`)

  // Track processed child IDs
  const processedChildIds = []

  // Process each template child
  for (const templateChild of templateChildren) {
    const childName = templateChild.private?.name?.at(0)?.string

    if (!childName) {
      log(`  Skipping child without name: ${templateChild._id}`)
      continue
    }

    // Find matching child in destination
    const destChild = await destDb.collection('entity').findOne(
      {
        'private._type.string': 'property',
        'private._parent.reference': destEntity._id,
        'private.name.string': childName
      },
      {
        projection: { _id: true }
      }
    )

    if (destChild) {
      log(`  Updating child: ${childName}`)

      processedChildIds.push(destChild._id)

      // Copy properties from template to destination child
      const newChildProps = await copyPropertiesFromTemplate(
        templateDb,
        destDb,
        database,
        templateChild._id,
        destChild._id,
        'property'
      )

      // Add _parent property with correct reference to destination entity (only if not already set)
      const hasChildParent = await destDb.collection('property').findOne({
        entity: destChild._id,
        type: '_parent',
        reference: destEntity._id,
        deleted: { $exists: false }
      })

      if (!hasChildParent) {
        newChildProps.push({
          entity: destChild._id,
          type: '_parent',
          reference: destEntity._id,
          created: {
            at: new Date()
          }
        })
      }

      if (newChildProps.length > 0) {
        await destDb.collection('property').insertMany(newChildProps)
      }

      // Aggregate the updated child entity
      await sendAggregateToApi(database, destChild._id)
    }
    else {
      log(`  Child not found in destination: ${childName} - creating new one`)

      // Create empty entity document
      const result = await destDb.collection('entity').insertOne({})
      const newDestChild = { _id: result.insertedId }

      processedChildIds.push(newDestChild._id)

      // Copy properties from template to new child
      const newChildProps = await copyPropertiesFromTemplate(
        templateDb,
        destDb,
        database,
        templateChild._id,
        newDestChild._id,
        'property'
      )

      // Add _parent property to link to parent entity
      newChildProps.push({
        entity: newDestChild._id,
        type: '_parent',
        reference: destEntity._id,
        created: {
          at: new Date()
        }
      })

      if (newChildProps.length > 0) {
        await destDb.collection('property').insertMany(newChildProps)
      }

      // Aggregate the new child entity
      await sendAggregateToApi(database, newDestChild._id)
    }

    // Aggregate the updated entity
    await sendAggregateToApi(database, destEntity._id)
  }

  // If overwrite is true, delete children from destination that weren't processed
  if (overwrite) {
    log(`  Processed child IDs: ${processedChildIds.length}`)

    const destChildren = await destDb.collection('entity')
      .find(
        {
          'private._type.string': 'property',
          'private._parent.reference': destEntity._id,
          _id: { $nin: processedChildIds }
        },
        {
          projection: { _id: true, 'private.name': true }
        }
      )
      .toArray()

    log(`  Children to potentially delete: ${destChildren.length}`)

    for (const destChild of destChildren) {
      const destChildName = destChild.private?.name?.at(0)?.string

      // Check if this entity already has a _deleted property
      const hasDeletedProperty = await destDb.collection('property').findOne({
        entity: destChild._id,
        type: '_deleted',
        deleted: { $exists: false }
      })

      if (!hasDeletedProperty) {
        log(`  Deleting child not in template: ${destChildName} (ID: ${destChild._id})`)

        // Add _deleted property to mark entity as deleted
        await destDb.collection('property').insertOne({
          entity: destChild._id,
          type: '_deleted',
          datetime: new Date(),
          created: {
            at: new Date()
          }
        })

        // Aggregate the deleted child entity
        await sendAggregateToApi(database, destChild._id)
      }
      else {
        log(`  Skipping already deleted child: ${destChildName} (ID: ${destChild._id})`)
      }
    }
  }

  log('  Entity definition copied')
}

async function copyPropertiesFromTemplate (templateDb, destDb, database, templateEntityId, destEntityId, entityTypeName) {
  const systemTypes = ['_viewer', '_expander', '_editor', '_owner', '_created', '_parent', '_type']

  // Map this pair up front so self and circular references resolve to the destination entity
  referenceCache.set(templateEntityId.toString(), destEntityId)

  // Get template entity properties (excluding reference properties and system properties)
  const templateProperties = await templateDb.collection('property')
    .find({
      entity: templateEntityId,
      type: { $nin: systemTypes },
      reference: { $exists: false },
      deleted: { $exists: false }
    })
    .toArray()

  // Get existing destination properties (excluding reference and system properties) - references are synced separately below
  const destProperties = await destDb.collection('property')
    .find({
      entity: destEntityId,
      type: { $nin: systemTypes },
      reference: { $exists: false },
      deleted: { $exists: false }
    })
    .toArray()

  // Fields used for value comparison
  const valueFields = ['string', 'number', 'boolean', 'datetime', 'filename', 'filesize', 'filetype', 'url', 'formula', 'language']
  const getValueKey = (prop) => valueFields.map((f) => `${f}:${prop[f] ?? ''}`).join('|')

  const templateTypes = [...new Set(templateProperties.map((p) => p.type))]
  const destTypes = [...new Set(destProperties.map((p) => p.type))]

  const typesToDelete = []
  const newProperties = []

  // Find types that differ or are new in template
  for (const type of templateTypes) {
    const tmplProps = templateProperties.filter((p) => p.type === type)
    const destProps = destProperties.filter((p) => p.type === type)

    const tmplKeys = tmplProps.map(getValueKey).sort()
    const destKeys = destProps.map(getValueKey).sort()
    const same = tmplKeys.length === destKeys.length && tmplKeys.every((k, i) => k === destKeys[i])

    if (!same) {
      typesToDelete.push(type)
      for (const prop of tmplProps) {
        newProperties.push({ ...prop, _id: undefined, entity: destEntityId, created: { at: new Date() } })
      }
    }
  }

  // Remove types that exist in destination but not in template
  for (const type of destTypes) {
    if (!templateTypes.includes(type)) {
      typesToDelete.push(type)
    }
  }

  // Soft-delete only the affected property types
  if (typesToDelete.length > 0) {
    await destDb.collection('property').updateMany(
      {
        entity: destEntityId,
        type: { $in: typesToDelete },
        reference: { $exists: false },
        deleted: { $exists: false }
      },
      {
        $set: { deleted: { at: new Date() } }
      }
    )
  }

  // Get template reference properties that are allowed to be copied
  const templateReferences = await templateDb.collection('property')
    .find({
      entity: templateEntityId,
      type: { $in: Object.keys(REFERENCE_TYPES) },
      reference: { $exists: true },
      deleted: { $exists: false }
    })
    .toArray()

  // Add template references missing in destination - additive only, destination's own references are never removed
  for (const prop of templateReferences) {
    const destReferenceId = await getDestinationReference(templateDb, destDb, database, prop.reference, REFERENCE_TYPES[prop.type])

    if (!destReferenceId) continue

    const hasReference = await destDb.collection('property').findOne({
      entity: destEntityId,
      type: prop.type,
      reference: destReferenceId,
      deleted: { $exists: false }
    })

    if (!hasReference) {
      newProperties.push({ ...prop, _id: undefined, entity: destEntityId, reference: destReferenceId, created: { at: new Date() } })
    }
  }

  // Find and add _type property pointing to correct entity (only if not already set)
  const typeEntity = await destDb.collection('entity').findOne(
    {
      'private._type.string': 'entity',
      'private.name.string': entityTypeName
    },
    { projection: { _id: true } }
  )

  if (typeEntity) {
    const hasType = await destDb.collection('property').findOne({
      entity: destEntityId,
      type: '_type',
      reference: typeEntity._id,
      deleted: { $exists: false }
    })

    if (!hasType) {
      newProperties.push({
        entity: destEntityId,
        type: '_type',
        reference: typeEntity._id,
        created: {
          at: new Date()
        }
      })
    }
  }

  // Add _created property only if it doesn't already exist
  const hasCreated = await destDb.collection('property').findOne({
    entity: destEntityId,
    type: '_created',
    deleted: { $exists: false }
  })

  if (!hasCreated) {
    newProperties.push({
      entity: destEntityId,
      type: '_created',
      datetime: new Date(),
      created: {
        at: new Date()
      }
    })
  }

  return newProperties
}

// Returns the destination entity matching a template entity of the expected type by name, creating it from the template when missing
async function getDestinationReference (templateDb, destDb, database, templateReferenceId, expectedType) {
  const templateReference = await templateDb.collection('entity').findOne(
    { _id: templateReferenceId },
    { projection: { 'private._type.string': true, 'private.name.string': true, 'private.url.string': true } }
  )

  const type = templateReference?.private?._type?.at(0)?.string
  const names = templateReference?.private?.name?.map((x) => x.string).filter(Boolean) || []
  const url = templateReference?.private?.url?.at(0)?.string

  // Skip references pointing to another entity type (e.g. add_from to an entity type), to a nameless entity or to a plugin without url
  if (type !== expectedType || names.length === 0 || (type === 'plugin' && !url)) {
    return null
  }

  const cacheKey = templateReferenceId.toString()

  if (referenceCache.has(cacheKey)) {
    return referenceCache.get(cacheKey)
  }

  // Plugins receive user tokens, so they match by url (as importPlugins does) - a same-named plugin pointing elsewhere is never linked
  const matchFilter = type === 'plugin' ? { 'private.url.string': { $in: [url] } } : { 'private.name.string': { $in: names } }

  // Find destination entity with same type and name (any language) or url
  const destReference = await destDb.collection('entity').findOne(
    {
      'private._type.string': type,
      ...matchFilter
    },
    { projection: { _id: true } }
  )

  if (destReference) {
    referenceCache.set(cacheKey, destReference._id)

    // Existing menus and plugins must have the database entity as parent too
    const parentProperties = await getDatabaseParentProperties(destDb, destReference._id)

    if (parentProperties.length > 0) {
      await destDb.collection('property').insertMany(parentProperties)
      await sendAggregateToApi(database, destReference._id)
    }

    return destReference._id
  }

  log(`  Referenced ${type} "${names.at(0)}" not found in destination - creating new one`)

  // Create empty entity document (all data comes from properties)
  const result = await destDb.collection('entity').insertOne({})
  const newProperties = await copyPropertiesFromTemplate(
    templateDb,
    destDb,
    database,
    templateReferenceId,
    result.insertedId,
    type
  )

  newProperties.push(...await getDatabaseParentProperties(destDb, result.insertedId))

  await destDb.collection('property').insertMany(newProperties)

  // Aggregate the new referenced entity
  await sendAggregateToApi(database, result.insertedId)

  return result.insertedId
}

// Returns the _parent property linking the entity to the database entity, or nothing when it is already set
async function getDatabaseParentProperties (destDb, entityId) {
  const destDatabase = await destDb.collection('entity').findOne(
    { 'private._type.string': 'database' },
    { projection: { _id: true } }
  )

  if (!destDatabase) {
    log('  Database entity not found - _parent not set')

    return []
  }

  const hasParent = await destDb.collection('property').findOne({
    entity: entityId,
    type: '_parent',
    reference: destDatabase._id,
    deleted: { $exists: false }
  })

  if (hasParent) {
    return []
  }

  return [{
    entity: entityId,
    type: '_parent',
    reference: destDatabase._id,
    created: {
      at: new Date()
    }
  }]
}
