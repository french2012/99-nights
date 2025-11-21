const fs = require('fs')
const path = require('path')

function log(...args) { console.log(...args) }

const placeArg = process.argv[2]
const placeId = placeArg || process.env.ROBLOX_PLACE_ID || ''
const cookie = process.env.ROBLOX_SECURITY || ''

log('Roblox Admin deploy helper')
log('--------------------------------')

if (!fs.existsSync(path.join(__dirname, '..', 'roblox-dev-admin'))) {
  log('Error: roblox-dev-admin folder not found in repo root. Nothing to deploy.')
  process.exit(1)
}

if (!cookie) {
  log('No ROBLOX_SECURITY secret detected. The workflow packaged the scripts as an artifact named "admin-scripts".')
  log('To enable automatic publishing, add a GitHub Actions secret named ROBLOX_SECURITY with your .ROBLOSECURITY cookie.')
  log('See README for exact setup steps. You can still download the artifact and import the scripts into Roblox Studio manually.')
  process.exit(0)
}

if (!placeId) {
  log('No Place ID provided (as workflow input or ROBLOX_PLACE_ID secret).')
  log('Set the workflow input `place_id` when triggering the workflow, or add a secret ROBLOX_PLACE_ID.')
  log('The script will not attempt to publish until a Place ID is provided.')
  process.exit(0)
}

// If secrets and place id are present, call the publish helper. publish.js is a scaffold
// that logs in using noblox.js. It can be extended to perform the actual in-place
// script updates. For now it provides a safe login check and next-step instructions.
const publishScript = path.join(__dirname, 'publish.js')
if (fs.existsSync(publishScript)) {
  log(`Calling publish helper with place id: ${placeId}`)
  const { spawnSync } = require('child_process')
  const result = spawnSync('node', [publishScript, placeId], { stdio: 'inherit', env: process.env })
  process.exit(result.status)
} else {
  log('Publish helper not found; nothing else to do.')
  process.exit(0)
}
