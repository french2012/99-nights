const noblox = require('noblox.js')
const fs = require('fs')
const path = require('path')

async function main() {
  const cookie = process.env.ROBLOX_SECURITY
  const placeIdEnv = process.argv[2] || process.env.ROBLOX_PLACE_ID || ''

  if (!cookie) {
    console.error('ROBLOX_SECURITY is not set. Add it as a GitHub Actions secret.')
    process.exit(1)
  }

  if (!placeIdEnv) {
    console.error('No place id provided. Provide as workflow input `place_id` or set ROBLOX_PLACE_ID secret.')
    process.exit(1)
  }

  const placeId = Number(placeIdEnv)
  if (!Number.isFinite(placeId)) {
    console.error('Invalid place id:', placeIdEnv)
    process.exit(1)
  }

  console.log('Logging in to Roblox...')
  try {
    await noblox.setCookie(cookie)
    const user = await noblox.getCurrentUser()
    console.log(`Logged in as ${user.UserName} (${user.UserId})`)
  } catch (err) {
    console.error('Failed to login via noblox.js:', err)
    process.exit(1)
  }

  // NOTE: Programmatic editing of a place's instance hierarchy is non-trivial.
  // The safe approach here is to create a place file (.rbxlx/.rbxm) containing
  // the Scripts/LocalScripts you want to update and then publish that place file
  // using Roblox's place upload APIs. The exact implementation depends on whether
  // you want to completely replace the place or update specific Script instances.

  // This helper will:
  // 1) Build a minimal place package containing the Scripts from `roblox-dev-admin`.
  // 2) Upload the package as a new version of the place or create script instances.
  // 3) Optionally save backups of current scripts (if requested via env var).

  // Currently this file is a safe scaffold. To complete automatic publishing you
  // should implement one of the strategies below (I can implement it for you):
  // - Overwrite place: generate an .rbxlx that contains all required instances and
  //   call the upload/publish APIs to replace the place content (destructive).
  // - Update scripts in-place: retrieve the place, locate Scripts by name and
  //   update their Source. This requires the correct use of the Roblox private
  //   APIs and careful testing (safer but more involved).

  console.log('\nREADY: publish script scaffold is in place.')
  console.log('Next steps (manual):')
  console.log('- Add ROBLOX_SECURITY as a GitHub secret in your repo.')
  console.log('- Decide publish strategy: overwrite place OR update scripts in-place.')
  console.log('- If you want me to implement the final publish step, reply in chat with:')
  console.log('    "Implement publish-in-place with backups" or "Implement overwrite publish"')

  process.exit(0)
}

main()
