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

// At this point we have both cookie and placeId. Implementing a full automatic place update requires
// handling Roblox place file formats (.rbxlx/.rbxm) and using Roblox publish APIs. That code varies
// depending on whether you want to replace the place, update existing scripts, or insert assets.

log(`All required secrets provided. Ready to deploy to Place ID: ${placeId}`)
log('Automatic publishing is not enabled in this template. To enable it, extend scripts/deploy.js to:')
log('- build a .rbxlx/.rbxm package containing the desired Scripts/LocalScripts (the repo already contains script sources)')
log('- use an authenticated Roblox API client (for example, noblox.js) to upload the place or update scripts in-place')
log('If you want, I can implement the publish step for you once you confirm the exact replacement strategy (overwrite place vs update scripts).')

process.exit(0)
