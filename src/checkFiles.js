// eslint-disable-next-line no-unused-vars
import dotenv from 'dotenv/config'

import { MongoClient } from 'mongodb'
import { S3Client, HeadObjectCommand } from '@aws-sdk/client-s3'
import { appendFileSync, writeFileSync } from 'fs'
import { log } from './helpers.js'

const mongoClient = new MongoClient(process.env.MONGODB)
const mongoDbList = await mongoClient.db().admin().listDatabases()
const dbList = mongoDbList.databases.filter((db) => !['admin', 'analytics', 'config', 'local'].includes(db.name)).map((db) => db.name)

// const dbList = [
// ]

// Initialize CSV file with header
writeFileSync('files.csv', 'STATUS;DATABASE;KEY;DB_SIZE;DO_SIZE;S3_SIZE;DELETED\n')

const spacesClient = new S3Client({
  endpoint: process.env.DO_SPACES_ENDPOINT,
  region: process.env.DO_SPACES_REGION,
  credentials: {
    accessKeyId: process.env.DO_SPACES_KEY,
    secretAccessKey: process.env.DO_SPACES_SECRET
  }
})

const s3Client = new S3Client({
  endpoint: process.env.AWS_S3_ENDPOINT,
  region: process.env.AWS_S3_REGION,
  credentials: {
    accessKeyId: process.env.AWS_S3_KEY,
    secretAccessKey: process.env.AWS_S3_SECRET
  }
})

for (let i = 0; i < dbList.length; i++) {
  const dbName = dbList.at(i)
  const files = await mongoClient
    .db(dbName)
    .collection('property')
    .find({
      $or: [
        { filename: { $exists: true } },
        { filesize: { $exists: true } },
        { s3: { $exists: true } }
      ],
      url: { $exists: false }
      // deleted: { $exists: false }
    }, {
      projection: {
        _id: true,
        entity: true,
        type: true,
        filename: true,
        filesize: true,
        s3: true,
        deleted: true
      }
    })
    .toArray()

  log(`${dbName} - ${files.length}`)

  for (let j = 0; j < files.length; j++) {
    const f = files.at(j)
    const key = `${dbName}/${f.entity}/${f._id}`
    const isDeleted = f.deleted ? 'YES' : ''

    let doFileInfo
    let s3FileInfo
    let doFound = false
    let s3Found = false

    // Check DigitalOcean Spaces
    try {
      doFileInfo = await getDOFile(key)
      doFound = true
    }
    catch (error) {
      if (error.name !== 'NotFound') {
        log(`${dbName} - Error accessing DO file: ${key} - ${error.message}`)
        continue
      }
    }

    // Check AWS S3
    try {
      s3FileInfo = await getAWSFile(key)
      s3Found = true
    }
    catch (s3error) {
      if (s3error.name !== 'NotFound') {
        log(`${dbName} - Error accessing S3 (${process.env.AWS_S3_BUCKET}) file: ${key} - ${s3error}`)
        continue
      }
    }

    // Analyze results
    if (!doFound && !s3Found) {
      appendFileSync('files.csv', `MISSING_BOTH;${dbName};${key};${f.filesize || ''};;;${isDeleted}\n`)
    }
    else if (!doFound && s3Found) {
      appendFileSync('files.csv', `MISSING_DO;${dbName};${key};${f.filesize || ''};${s3FileInfo.ContentLength};${isDeleted}\n`)
    }
    else if (doFound && !s3Found) {
      appendFileSync('files.csv', `MISSING_S3;${dbName};${key};${f.filesize || ''};${doFileInfo.ContentLength};${isDeleted}\n`)
    }
    else if (doFound && s3Found) {
      // Both files exist, check sizes
      const doSize = doFileInfo.ContentLength
      const s3Size = s3FileInfo.ContentLength
      const dbSize = f.filesize

      if (doSize === s3Size && doSize === dbSize) {
        // All sizes match - perfect, no logging needed for OK files
        // appendFileSync('files.csv', `OK;${dbName};${key};${dbSize};${doSize};${s3Size};${isDeleted}\n`)
      }
      else if (doSize === s3Size) {
        // DO and S3 match but differ from DB
        appendFileSync('files.csv', `MISMATCH_DB;${dbName};${key};${dbSize};${doSize};${s3Size};${isDeleted}\n`)
      }
      else if (doSize === dbSize) {
        // DO and DB match but S3 differs
        appendFileSync('files.csv', `MISMATCH_S3;${dbName};${key};${dbSize};${doSize};${s3Size};${isDeleted}\n`)
      }
      else if (s3Size === dbSize) {
        // S3 and DB match but DO differs
        appendFileSync('files.csv', `MISMATCH_DO;${dbName};${key};${dbSize};${doSize};${s3Size};${isDeleted}\n`)
      }
      else {
        // All three sizes are different
        appendFileSync('files.csv', `MISMATCH_ALL;${dbName};${key};${dbSize};${doSize};${s3Size};${isDeleted}\n`)
      }

      // Check for empty files
      if (doSize === 0 || s3Size === 0) {
        appendFileSync('files.csv', `EMPTY_FILE;${dbName};${key};${dbSize};${doSize};${s3Size};${isDeleted}\n`)
      }
    }

    if (j > 0 && j % 1000 === 0) {
      log(`${dbName} - Processed ${j} files`)
    }
  }
}

async function getDOFile (key) {
  const headCommand = new HeadObjectCommand({ Bucket: process.env.DO_SPACES_BUCKET, Key: key })

  return await spacesClient.send(headCommand)
}

async function getAWSFile (key) {
  const headCommand = new HeadObjectCommand({ Bucket: process.env.AWS_S3_BUCKET, Key: key })

  return await s3Client.send(headCommand)
}

process.exit()
