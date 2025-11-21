#!/usr/bin/env node
// Simple Node installer to download and extract admin-scripts.zip
// Usage: node downloaders/installer.js [destination]

const https = require('https')
const fs = require('fs')
const path = require('path')
const unzipper = require('unzipper')

const URL = 'https://github.com/french2012/99-nights/raw/main/admin-scripts.zip'
const OUT = path.resolve(process.cwd(), 'admin-scripts.zip')
const DEST = path.resolve(process.cwd(), process.argv[2] || 'admin-scripts')

function download(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest)
    https.get(url, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return download(res.headers.location, dest).then(resolve).catch(reject)
      }
      if (res.statusCode !== 200) return reject(new Error('Download failed: ' + res.statusCode))
      res.pipe(file)
      file.on('finish', () => file.close(resolve))
    }).on('error', (err) => {
      fs.unlink(dest, () => {})
      reject(err)
    })
  })
}

async function main() {
  try {
    console.log('Downloading admin-scripts.zip...')
    await download(URL, OUT)
    console.log('Extracting to', DEST)
    await fs.promises.mkdir(DEST, { recursive: true })
    await fs.createReadStream(OUT).pipe(unzipper.Extract({ path: DEST })).promise()
    console.log('Done. Files are in', path.join(DEST, 'roblox-dev-admin'))
  } catch (err) {
    console.error('Error:', err.message || err)
    process.exit(1)
  }
}

main()
