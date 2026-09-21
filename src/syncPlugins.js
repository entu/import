import dotenv from 'dotenv/config'

import { MongoClient } from 'mongodb'
import { log, sendAggregateToApi } from './helpers.js'

// Configuration
const TEMPLATE_DB = 'roots'

const mongoClient = new MongoClient(process.env.MONGODB)
const mongoDbList = await mongoClient.db().admin().listDatabases()
let dbList = []

dbList = mongoDbList.databases
  .filter((db) => !['admin', 'analytics', 'config', 'entu', 'local', TEMPLATE_DB].includes(db.name))
  .map((db) => db.name)

// dbList = [
//   'roots'
// ]

const mongo = await mongoClient.connect()
const templateDb = mongo.db(TEMPLATE_DB)

// Get plugin entities from template database
const templatePlugins = await templateDb.collection('entity')
  .find(
    {
      'private._type.string': 'plugin'
    },
    {
      projection: { _id: true, 'private.name': true, 'private.url': true }
    }
  )
  .toArray()

const templatePluginIds = templatePlugins.map((x) => x._id)

// Get all template plugin properties with one query
const systemTypes = ['_viewer', '_expander', '_editor', '_owner', '_created', '_parent', '_type']

const templateProperties = await templateDb.collection('property')
  .find({
    entity: { $in: templatePluginIds },
    type: { $nin: systemTypes },
    reference: { $exists: false },
    deleted: { $exists: false }
  })
  .toArray()

// Get entity types linked to template plugins with one query
const linkedTypes = await templateDb.collection('entity')
  .find(
    {
      'private._type.string': 'entity',
      'private.plugin.reference': { $in: templatePluginIds }
    },
    {
      projection: { 'private.name': true, 'private.plugin': true }
    }
  )
  .toArray()

// Get template plugin add_from references with one query
const templateAddFroms = await templateDb.collection('property')
  .find({
    entity: { $in: templatePluginIds },
    type: 'add_from',
    reference: { $exists: true },
    deleted: { $exists: false }
  })
  .toArray()

// Get menus referenced by add_from with one query - add_from to any other entity type is not copied
const templateMenus = await templateDb.collection('entity')
  .find(
    {
      _id: { $in: templateAddFroms.map((x) => x.reference) },
      'private._type.string': 'menu'
    },
    {
      projection: { _id: true, 'private.name': true }
    }
  )
  .toArray()

// Get all template menu properties with one query
const templateMenuProperties = await templateDb.collection('property')
  .find({
    entity: { $in: templateMenus.map((x) => x._id) },
    type: { $nin: systemTypes },
    reference: { $exists: false },
    deleted: { $exists: false }
  })
  .toArray()

for (const templateMenu of templateMenus) {
  templateMenu.names = templateMenu.private?.name?.map((x) => x.string).filter(Boolean) || []
  templateMenu.properties = templateMenuProperties.filter((x) => x.entity.equals(templateMenu._id))
}

for (const templatePlugin of templatePlugins) {
  templatePlugin.url = templatePlugin.private?.url?.at(0)?.string
  templatePlugin.name = templatePlugin.private?.name?.at(0)?.string
  templatePlugin.properties = templateProperties.filter((x) => x.entity.equals(templatePlugin._id))
  templatePlugin.menus = templateMenus
    .filter((x) => x.names.length > 0)
    .filter((x) => templateAddFroms.some((p) => p.entity.equals(templatePlugin._id) && p.reference.equals(x._id)))
  templatePlugin.types = linkedTypes
    .filter((x) => x.private?.plugin?.some((p) => p.reference?.equals(templatePlugin._id)))
    .map((x) => x.private?.name?.at(0)?.string)
    .filter(Boolean)
}

const plugins = templatePlugins.filter((x) => x.url)

log(`Template plugins: ${plugins.map((x) => `${x.name} (${x.types.join(', ') || 'no types'})`).join(', ')}`)
log(`Databases: ${dbList.join(', ')}`)
console.log('')

for (let i = 0; i < dbList.length; i++) {
  const database = dbList[i]
  log(`${database} - Start`)

  await syncPlugins(database)

  log(`${database} - End`)
  console.log('')
}

process.exit()

async function syncPlugins (database) {
  const db = mongo.db(database)

  // Get plugin entity type
  const pluginType = await db.collection('entity').findOne(
    {
      'private._type.string': 'entity',
      'private.name.string': 'plugin'
    },
    {
      projection: { _id: true }
    }
  )

  if (!pluginType) {
    log('  Entity type "plugin" not found')
    return
  }

  for (const plugin of plugins) {
    const pluginId = await upsertPlugin(db, database, plugin, pluginType._id)

    for (const typeName of plugin.types) {
      await linkToEntityType(db, database, typeName, pluginId, plugin.name)
    }

    for (const menu of plugin.menus) {
      await linkToMenu(db, database, menu, pluginId, plugin.name)
    }
  }
}

// Creates the plugin entity or rewrites its properties from template when an entity with the same url exists
async function upsertPlugin (db, database, plugin, pluginTypeId) {
  let pluginEntity = await db.collection('entity').findOne(
    {
      'private._type.string': 'plugin',
      'private.url.string': plugin.url
    },
    {
      projection: { _id: true }
    }
  )

  const newProperties = []

  if (pluginEntity) {
    log(`  Updating plugin: ${plugin.name} (${pluginEntity._id})`)
  }
  else {
    log(`  Creating plugin: ${plugin.name}`)

    // Create empty entity document (all data comes from properties)
    const result = await db.collection('entity').insertOne({})

    pluginEntity = { _id: result.insertedId }

    newProperties.push(...getNewEntityProperties(pluginEntity._id, pluginTypeId))
  }

  newProperties.push(
    ...await getDatabaseParentProperties(db, pluginEntity._id),
    ...await syncProperties(db, plugin.properties, pluginEntity._id)
  )

  if (newProperties.length > 0) {
    await db.collection('property').insertMany(newProperties)
    log(`  Properties updated: ${newProperties.length}`)

    await sendAggregateToApi(database, pluginEntity._id)
  }

  return pluginEntity._id
}

// Returns the _type and _created properties of a newly created entity
function getNewEntityProperties (entityId, typeId) {
  return [
    {
      entity: entityId,
      type: '_type',
      reference: typeId,
      created: {
        at: new Date()
      }
    },
    {
      entity: entityId,
      type: '_created',
      datetime: new Date(),
      created: {
        at: new Date()
      }
    }
  ]
}

// Returns the _parent property linking the entity to the database entity, or nothing when it is already set
async function getDatabaseParentProperties (db, entityId) {
  const databaseEntity = await db.collection('entity').findOne(
    { 'private._type.string': 'database' },
    { projection: { _id: true } }
  )

  if (!databaseEntity) {
    log('  Database entity not found - _parent not set')

    return []
  }

  const hasParent = await db.collection('property').findOne({
    entity: entityId,
    type: '_parent',
    reference: databaseEntity._id,
    deleted: { $exists: false }
  })

  if (hasParent) {
    return []
  }

  return [{
    entity: entityId,
    type: '_parent',
    reference: databaseEntity._id,
    created: {
      at: new Date()
    }
  }]
}

// Writes template properties to the destination entity, rewriting only property types that differ
async function syncProperties (db, templateProperties, destEntityId) {
  const destProperties = await db.collection('property')
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
    await db.collection('property').updateMany(
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

  return newProperties
}

// Adds a plugin reference to the entity type found by name, skipping when already linked
async function linkToEntityType (db, database, typeName, pluginId, pluginName) {
  const entityType = await db.collection('entity').findOne(
    {
      'private._type.string': 'entity',
      'private.name.string': typeName
    },
    {
      projection: { _id: true }
    }
  )

  if (!entityType) {
    log(`  Entity type "${typeName}" not found - skipping ${pluginName} link`)
    return
  }

  const hasLink = await db.collection('property').findOne({
    entity: entityType._id,
    type: 'plugin',
    reference: pluginId,
    deleted: { $exists: false }
  })

  // Entity types must have the database entity as parent
  const newProperties = await getDatabaseParentProperties(db, entityType._id)

  if (hasLink) {
    log(`  Entity type "${typeName}" already links ${pluginName}`)
  }
  else {
    newProperties.push({
      entity: entityType._id,
      type: 'plugin',
      reference: pluginId,
      created: {
        at: new Date()
      }
    })

    log(`  Linked ${pluginName} to entity type "${typeName}"`)
  }

  if (newProperties.length === 0) return

  await db.collection('property').insertMany(newProperties)
  await sendAggregateToApi(database, entityType._id)
}

// Adds an add_from reference from the plugin to the menu found by name, creating the menu from template when missing
async function linkToMenu (db, database, menu, pluginId, pluginName) {
  const menuName = menu.names.at(0)

  // Find destination menu with same name (any language)
  let menuEntity = await db.collection('entity').findOne(
    {
      'private._type.string': 'menu',
      'private.name.string': { $in: menu.names }
    },
    {
      projection: { _id: true }
    }
  )

  const isNewMenu = !menuEntity

  if (isNewMenu) {
    const menuType = await db.collection('entity').findOne(
      {
        'private._type.string': 'entity',
        'private.name.string': 'menu'
      },
      {
        projection: { _id: true }
      }
    )

    if (!menuType) {
      log(`  Entity type "menu" not found - skipping ${pluginName} link to menu "${menuName}"`)
      return
    }

    log(`  Creating menu: ${menuName}`)

    // Create empty entity document (all data comes from properties)
    const result = await db.collection('entity').insertOne({})

    menuEntity = { _id: result.insertedId }

    await db.collection('property').insertMany([
      ...getNewEntityProperties(menuEntity._id, menuType._id),
      ...await syncProperties(db, menu.properties, menuEntity._id)
    ])
  }

  // New and existing menus must have the database entity as parent
  const parentProperties = await getDatabaseParentProperties(db, menuEntity._id)

  if (parentProperties.length > 0) {
    await db.collection('property').insertMany(parentProperties)
  }

  if (isNewMenu || parentProperties.length > 0) {
    await sendAggregateToApi(database, menuEntity._id)
  }

  const hasLink = await db.collection('property').findOne({
    entity: pluginId,
    type: 'add_from',
    reference: menuEntity._id,
    deleted: { $exists: false }
  })

  if (hasLink) {
    log(`  ${pluginName} already links menu "${menuName}"`)
    return
  }

  await db.collection('property').insertOne({
    entity: pluginId,
    type: 'add_from',
    reference: menuEntity._id,
    created: {
      at: new Date()
    }
  })

  log(`  Linked ${pluginName} to menu "${menuName}"`)

  await sendAggregateToApi(database, pluginId)
}
