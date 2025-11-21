local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local TeleportEvent = ReplicatedStorage:WaitForChild("TeleportRequest")
local GiveWeaponEvent = ReplicatedStorage:WaitForChild("GiveWeapon")

local function isAdmin(player)
    if player.UserId == game.CreatorId then return true end
    local whitelist = {
        -- add other developer UserIds here: [12345678] = true,
    }
    return whitelist[player.UserId] == true
end

-- Teleport safety & rate-limiting
local TELEPORT_COOLDOWN = 2 -- seconds per player
local MAX_TELEPORT_DISTANCE = 700 -- studs
local lastTeleport = {}

TeleportEvent.OnServerEvent:Connect(function(player, targetPos)
    if not isAdmin(player) then return end
    if typeof(targetPos) ~= "Vector3" then return end
    local now = tick()
    local last = lastTeleport[player.UserId] or 0
    if now - last < TELEPORT_COOLDOWN then return end

    local char = player.Character
    if not char then return end
    local root = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- distance check from player's current position
    local currentPos = root.Position
    if (targetPos - currentPos).Magnitude > MAX_TELEPORT_DISTANCE then
        return
    end

    -- safety: use a downward raycast to find ground at target
    local safePos = targetPos
    local success, result = pcall(function()
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = {player.Character}
        local origin = targetPos + Vector3.new(0, 50, 0)
        local direction = Vector3.new(0, -200, 0)
        return workspace:Raycast(origin, direction, params)
    end)

    if success and result and result.Position then
        safePos = result.Position
    else
        safePos = targetPos + Vector3.new(0, 5, 0)
    end

    -- final safety check: ensure there is enough headroom above the safePos
    local headOrigin = safePos + Vector3.new(0, 2, 0)
    local headCheck = workspace:Raycast(headOrigin, Vector3.new(0, 3, 0), RaycastParams.new())
    if headCheck then
        -- blocked above; abort teleport
        return
    end

    -- perform teleport and record time
    root.CFrame = CFrame.new(safePos + Vector3.new(0, 2, 0))
    lastTeleport[player.UserId] = now
end)

GiveWeaponEvent.OnServerEvent:Connect(function(player, weaponName)
    if not isAdmin(player) then return end
    if typeof(weaponName) ~= "string" then return end
    -- rate-limit giving weapons to avoid spam
    player._lastGive = player._lastGive or 0
    if tick() - player._lastGive < 1 then return end
    player._lastGive = tick()
    local weapon = ServerStorage:FindFirstChild(weaponName)
    if weapon and weapon:IsA("Tool") then
        local clone = weapon:Clone()
        clone.Parent = player.Backpack
    end
end)

-- Simple developer leaderstat for testing (infinite resources)
Players.PlayerAdded:Connect(function(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player

    local resources = Instance.new("IntValue")
    resources.Name = "Resources"
    resources.Value = 999999
    resources.Parent = stats
end)
