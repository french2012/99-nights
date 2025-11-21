Roblox Developer Admin Example for "99 Nights in the Forest"
=============================================================

Overview
--------
This folder contains a small, safe example Admin toolkit for Roblox Studio intended for use in your own place ("99 Nights in the Forest"). It provides:

- server-side admin actions (teleport, give Tool from ServerStorage, developer leaderstats)
- server-side NPC kid manager (pathfind or instant-teleport kids to the Base)
- client-side developer UI + hotkeys for testing
- a `weapon_names.txt` list you can edit and use as reference (place matching Tools in `ServerStorage`)

Important
---------
Use these scripts only in places you own or have explicit permission to modify. Do not use them to interfere with or exploit other people's games. These scripts are intentionally developer-only: the server scripts authorize actions based on the game's creator or a whitelist you can edit.

Files added
-----------
- `ServerScripts/AdminActions.lua` — Teleport/give weapon handlers and developer leaderstats.
- `ServerScripts/KidManager.lua` — Periodic pathfinding for NPC kids and instant teleport event.
- `ClientScripts/DevControls.lua` — LocalScript with hotkeys and a simple runtime UI for developer actions.
- `weapon_names.txt` — Example weapon/sack/item names from your project (edit to match Tools in `ServerStorage`).

Quick Install (Roblox Studio)
-----------------------------
1. Open your place in Roblox Studio (your own game).
2. In `ReplicatedStorage`, add three `RemoteEvent`s named exactly: `TeleportRequest`, `GiveWeapon`, `TeleportKidsToBase`.
3. Place your `Tool` instances (weapons/items/sack) into `ServerStorage` with the names you want. Ensure names match `weapon_names.txt` if using it.
4. In `Workspace` add a `Model` or `Part` named `Base` with `PrimaryPart` set (this is where kids will be escorted).
5. Add a `Folder` in `Workspace` named `Kids` and put your NPC models inside; each NPC must have a `Humanoid` and `HumanoidRootPart`.
6. Copy `AdminActions.lua` and `KidManager.lua` into `ServerScriptService`.
7. Copy `DevControls.lua` into `StarterPlayer > StarterPlayerScripts`.
8. Play in Studio (Play Solo). As the place owner (game creator) you'll be authorized to use the admin controls.

Controls
--------
- Hotkeys (developer only):
  - `T` — Teleport to mouse position.
  - `K` — Give the default weapon (first in `weapon_names.txt`, or pass a name).
  - `Y` — Teleport all kids to the Base instantly.
- UI: press the small developer button to open controls with buttons for teleport, give weapon, and teleport kids.

Customization
-------------
- Edit the `isAdmin` function in `AdminActions.lua` to add other developer UserIds to the whitelist.
- Replace or extend the UI in `DevControls.lua` if you prefer a different layout.
- Add Tools to `ServerStorage` named exactly as listed in `weapon_names.txt`.

If you'd like, I can also convert the UI into a fully featured admin panel, add safety checks to avoid teleporting into walls, or add persistent settings.

CI Deploy (template)
--------------------
I added a GitHub Actions template `/.github/workflows/deploy.yml` and a helper script `scripts/deploy.js`.
When you trigger the workflow it will:

- package the `roblox-dev-admin` folder into an artifact `admin-scripts.zip` (downloadable from the Actions run), and
- run `scripts/deploy.js` which will check for the presence of the secrets and place id.

To enable fully automated publish from GitHub (no Studio):

1. Add your Roblox `.ROBLOSECURITY` cookie as a GitHub repository secret named `ROBLOX_SECURITY`.
  - In GitHub: Settings → Secrets → Actions → New repository secret
  - Name: `ROBLOX_SECURITY`
  - Value: your .ROBLOSECURITY cookie string

2. (Optional) Add the place id as a secret named `ROBLOX_PLACE_ID`, or specify it when you trigger the workflow.

3. Trigger the workflow from the Actions tab → "Deploy Roblox Admin Scripts" → Run workflow → provide `place_id` input if you didn't set the secret.

Notes & next steps
-------------------
- The current template packages scripts and validates secrets/place id. It does NOT automatically publish into your Roblox place yet — publishing requires creating a `.rbxlx`/.`rbxm` package and calling Roblox APIs to upload it. The helper prints clear next steps and can be extended to perform the publish using `noblox.js`.
- If you want, I can implement the final publish step (overwrite place vs update scripts in-place). If you confirm which approach you want I will implement it in `scripts/deploy.js` and add the required npm dependency (for example, `noblox.js`) so the workflow will publish directly to your place when run.

Security reminder
-----------------
- Never paste your `.ROBLOSECURITY` cookie into chat. Add it only as a GitHub Actions secret.
- The admin scripts already check `game.CreatorId` and a whitelist, so only you (or whitelisted UserIds) will be able to use the dev tools in-game.
