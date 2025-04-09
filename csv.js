import fs from 'fs'
import path from 'path'
import yaml from 'yaml'
import { AsyncParser } from '@json2csv/node'

const database = 'vabamu'
const skipProperties = [
  'inventeerimuseaal',
  'inventeerirepr',
  'inventeerisari'
]
const headers = {
  Authorization: 'Bearer TOKEN'
}

console.log('\nFetching all types')

const types = await fetchAllEntities(database, { '_type.string': 'entity', props: 'name.string', sort: 'name.string' }, headers)
const typeNames = types.map((x) => x.name.at(0).string)

for (let i = 0; i < typeNames.length; i++) {
  const t = typeNames[i]
  console.log(`\nFetching ${t}`)

  const entities = await fetchAllEntities(database, { '_type.string': t }, headers)

  entitiesToCsv(entities, `./${database}/${t}.csv`)
}

async function fetchAllEntities (database, query = {}, headers = {}) {
  let skip = 0
  const limit = 500
  let allEntities = []
  let hasMore = true

  while (hasMore) {
    console.log(`Fetching ${skip + 1} - ${skip + limit}`)

    const q = new URLSearchParams({ ...query, limit, skip })
    const response = await fetch(`https://entu.app/api/${database}/entity?${q}`, { headers })

    if (!response.ok) {
      console.error(response.statusText, await response.text())
      return []
    }

    const { entities } = await response.json()

    hasMore = entities.length === limit
    allEntities = allEntities.concat(entities)
    skip += limit

    await new Promise((resolve) => setTimeout(resolve, 2000))
  }

  return allEntities
}

async function entitiesToCsv (entities, filename) {
  fs.mkdirSync(path.dirname(filename), { recursive: true })
  // fs.writeFileSync(filename.replace('.csv', '.yaml'), yaml.stringify(entities))

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]
    const newEntity = { _id: entity._id }

    const parent = entity._parent?.map((x) => x.reference).join('\n')
    if (parent) newEntity._parent = parent

    for (const propertyName in entity) {
      if (propertyName.startsWith('_') || skipProperties.includes(propertyName)) continue

      const element = entity[propertyName]

      newEntity[propertyName] = getValues(element, entity._id)
    }

    entities[i] = newEntity
  }

  if (entities.length === 0) return

  const parser = new AsyncParser()
  const csv = await parser.parse(entities).promise()

  fs.writeFileSync(filename, csv)
}

function getValues (element, entityId) {
  const elements = element.map((x) => {
    if (x.boolean !== undefined) return x.boolean ? 1 : 0
    if (x.date !== undefined) return x.date.substring(0, 10)
    if (x.datetime !== undefined) return x.datetime
    if (x.filename !== undefined) return `/${entityId}/${x._id} - ${x.filename}`
    if (x.number !== undefined) return x.number
    if (x.string !== undefined) return x.string

    return yaml.stringify(x).trim()
  })

  if (elements.length > 1) return elements.join('\n')

  return elements.at(0)
}
