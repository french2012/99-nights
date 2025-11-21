local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local kidsFolder = workspace:WaitForChild("Kids")
local baseModel = workspace:WaitForChild("Base")
local TeleportKidsEvent = ReplicatedStorage:WaitForChild("TeleportKidsToBase")

local function isValidKid(kid)
    return kid:FindFirstChildOfClass("Humanoid") and kid:FindFirstChild("HumanoidRootPart")
end

local function moveKidToBase(kid)
    if not isValidKid(kid) then return end
    local hrp = kid.HumanoidRootPart
    local humanoid = kid:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local startPos = hrp.Position
    local goalPos = baseModel.PrimaryPart.Position
    local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5})
    local success, message = pcall(function()
        path:ComputeAsync(startPos, goalPos)
    end)
    if not success then return end
    local waypoints = path:GetWaypoints()
    for _, wp in ipairs(waypoints) do
        if humanoid.Health <= 0 then return end
        humanoid:MoveTo(wp.Position)
        local ok = humanoid.MoveToFinished:Wait()
        if (hrp.Position - goalPos).Magnitude < 6 then
            break
        end
    end
end

-- Periodically try to send kids to base with coroutines so each kid runs independently
spawn(function()
    while true do
        for _, kid in pairs(kidsFolder:GetChildren()) do
            coroutine.wrap(function()
                moveKidToBase(kid)
            end)()
        end
        wait(5)
    end
end)

-- Instant teleport for authorized server callers
TeleportKidsEvent.OnServerEvent:Connect(function(player)
    -- Only allow the creator or whitelisted users. Adjust if you want more admins.
    if player.UserId ~= game.CreatorId then return end
    for _, kid in pairs(kidsFolder:GetChildren()) do
        if isValidKid(kid) then
            local hrp = kid.HumanoidRootPart
            hrp.CFrame = baseModel.PrimaryPart.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
        end
    end
end)
