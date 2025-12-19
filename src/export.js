// eslint-disable-next-line no-unused-vars
import dotenv from 'dotenv/config'

import fs from 'fs'
import path from 'path'
import yaml from 'yaml'
import { AsyncParser } from '@json2csv/node'
import { S3Client, HeadObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3'
import { log } from './helpers.js'

const filesPath = '../export'

const database = 'vabamu'
const skipProperties = [
  'inventeerimuseaal',
  'inventeerirepr',
  'inventeerisari'
]

const s3Client = new S3Client({
  endpoint: process.env.DO_SPACES_ENDPOINT,
  region: process.env.DO_SPACES_REGION || 'fra1',
  credentials: {
    accessKeyId: process.env.DO_SPACES_KEY,
    secretAccessKey: process.env.DO_SPACES_SECRET
  }
})

log(`Database: ${database}`)

const types = await fetchAllEntities(database, { '_type.string': 'entity', props: 'name.string', sort: 'name.string' })
// const types = await fetchAllEntities(database, { '_type.string': 'entity', 'name.string.ne': 'eksponaat', props: 'name.string', sort: 'name.string' })
// const types = await fetchAllEntities(database, { '_type.string': 'entity', 'name.string': 'eksponaat', props: 'name.string', sort: 'name.string' })
const typeNames = types.map((x) => x.name.at(0).string)

log(`Types: ${typeNames.join(', ')}`)

for (let i = 0; i < typeNames.length; i++) {
  const t = typeNames[i]
  console.log('')
  log(`Fetching ${t}`)

  const entities = await fetchAllEntities(database, { '_type.string': t })

  const outputPath = path.join(filesPath, database, t, `${t}.csv`)
  await entitiesToFile(entities, outputPath)
}

process.exit()

async function fetchAllEntities (database, query = {}) {
  let skip = 0
  const limit = 1000
  let allEntities = []
  let hasMore = true

  while (hasMore) {
    const start = Date.now()

    const q = new URLSearchParams({ ...query, limit, skip })
    const response = await fetch(`${process.env.ENTU_API_URL}/${database}/entity?${q}`, {
      headers: { Authorization: `Bearer ${process.env.ENTU_API_TOKEN}` }
    })

    if (!response.ok) {
      console.error(response.statusText, await response.text())
      return []
    }

    const { entities } = await response.json()

    hasMore = entities.length === limit
    allEntities = allEntities.concat(entities)

    const seconds = ((Date.now() - start) / 1000).toFixed(1)

    log(`Fetched ${skip + 1} - ${skip + entities.length} in ${seconds}s`)

    skip += limit

    await new Promise((resolve) => setTimeout(resolve, 1000))
  }

  return allEntities
}

async function entitiesToFile (entities, filename) {
  fs.mkdirSync(path.dirname(filename), { recursive: true })

  // Save all entities to yaml
  // fs.writeFileSync(filename.replace('.csv', '.yaml'), yaml.stringify(entities, { lineWidth: -1, sortMapEntries }))

  const entityType = path.basename(path.dirname(filename))

  // First pass: collect all possible field names
  const allFields = new Set(['_id'])

  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]

    if (entity._parent) allFields.add('_parent')

    for (const propertyName in entity) {
      if (propertyName.startsWith('_') || skipProperties.includes(propertyName)) continue
      allFields.add(propertyName)
    }
  }

  // Second pass: process entities and ensure all fields exist
  for (let i = 0; i < entities.length; i++) {
    const entity = entities[i]
    const newEntity = { _id: entity._id }

    const parent = entity._parent?.map((x) => x.reference).join('')
    if (parent) newEntity._parent = parent

    for (const propertyName in entity) {
      if (propertyName.startsWith('_') || skipProperties.includes(propertyName)) continue

      const element = entity[propertyName]
      newEntity[propertyName] = await getValues(element, entity._id, entityType, propertyName)
    }

    // Ensure all fields exist in this entity (set to null if missing)
    for (const field of allFields) {
      if (!(field in newEntity)) {
        newEntity[field] = null
      }
    }

    entities[i] = newEntity
  }

  if (entities.length === 0) return

  // Explicitly specify the fields for the CSV parser
  const parser = new AsyncParser({
    fields: Array.from(allFields).sort((a, b) => {
      if (a === '_id') return -1
      if (b === '_id') return 1
      if (a === '_parent') return -1
      if (b === '_parent') return 1
      return a.localeCompare(b)
    })
  })
  const csv = await parser.parse(entities).promise()

  fs.writeFileSync(filename, csv)
}

function sortMapEntries (a, b) {
  // _id should always come first
  if (a.key.value === '_id') return -1
  if (b.key.value === '_id') return 1

  // For all other keys, sort alphabetically
  if (a.key.value === b.key.value) return 0
  if (a.key.value < b.key.value) return -1

  return 1
}

function safeFilename (filename, maxLength = 64) {
  if (!filename) return ''

  const ext = path.extname(filename)
  const base = path.basename(filename, ext)

  if ((base + ext).length <= maxLength) return ` - ${filename}`

  return ` - ${base.slice(0, maxLength - ext.length - 3)}...${ext}`
}

async function getValues (element, entityId, entityType, propertyName) {
  const elements = []

  for (const x of element) {
    let value = yaml.stringify(x).trim()

    if (x.boolean !== undefined) value = x.boolean ? 1 : 0
    if (x.date !== undefined) value = x.date.substring(0, 10)
    if (x.datetime !== undefined) value = x.datetime
    if (x.filename !== undefined || x.filesize !== undefined) {
      const safeName = safeFilename(x.filename?.trim())
      const fileExists = await getFile(entityType, entityId, x._id, safeName, propertyName)

      if (!fileExists) continue

      value = `${entityType}/${propertyName}/${entityId}/${x._id}${safeName}`
    }
    if (x.number !== undefined) value = x.number
    if (x.reference !== undefined) value = [x.reference, x.string?.trim()].filter(Boolean).join(' - ')
    if (x.string !== undefined) value = x.string?.trim()

    if (x.language !== undefined) value = `${x.language.toLowerCase()} - ${value}`

    elements.push(value)
  }

  if (elements.length > 1) return elements.join('')

  return elements.at(0)
}

async function getFile (entityType, entityId, fileId, filename, propertyName) {
  try {
    const remoteKey = `${database}/${entityId}/${fileId}`

    // Check if file exists in DO Spaces
    const headCommand = new HeadObjectCommand({
      Bucket: process.env.DO_SPACES_BUCKET,
      Key: remoteKey
    })
    const remoteFileInfo = await s3Client.send(headCommand)

    // Skip empty files
    if (remoteFileInfo.ContentLength === 0) {
      log(`File is empty: ${entityType}/${propertyName}/${entityId}/${fileId}${filename}`)
      return false
    }

    // Prepare local file path
    const localFilePath = path.join(filesPath, database, entityType, propertyName, entityId, `${fileId}${filename}`)
    fs.mkdirSync(path.dirname(localFilePath), { recursive: true })

    // Check if file already exists locally with correct size
    if (fs.existsSync(localFilePath)) {
      const localFileStats = fs.statSync(localFilePath)

      if (localFileStats.size === remoteFileInfo.ContentLength) {
        // File already downloaded and size matches
        return true
      }
      else {
        // Size mismatch, need to re-download
        log(`File size mismatch, re-downloading: ${localFilePath}`)
      }
    }

    // Download the file from DO Spaces
    const downloadCommand = new GetObjectCommand({
      Bucket: process.env.DO_SPACES_BUCKET,
      Key: remoteKey
    })
    const fileResponse = await s3Client.send(downloadCommand)

    // Save file to local filesystem
    const writeStream = fs.createWriteStream(localFilePath)
    await new Promise((resolve, reject) => {
      fileResponse.Body.pipe(writeStream)
      fileResponse.Body.on('error', reject)
      writeStream.on('finish', resolve)
    })

    log(`Downloaded file: ${localFilePath}`)

    // Verify the downloaded file size matches remote
    const finalFileStats = fs.statSync(localFilePath)
    if (finalFileStats.size === remoteFileInfo.ContentLength) {
      return true
    }
    else {
      console.error(`Downloaded file size mismatch: ${localFilePath}`)
      return false
    }
  }
  catch (error) {
    if (error.name === 'NotFound' || error.$metadata?.httpStatusCode === 404) {
      log(`File not found: ${entityType}/${propertyName}/${entityId}/${fileId}${filename}`)
      return false
    }
    else {
      console.error(`Error checking/saving file: ${entityType}/${propertyName}/${entityId}/${fileId}${filename}`, error.message)
      return false
    }
  }
}
