local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local TeleportEvent = ReplicatedStorage:WaitForChild("TeleportRequest")
local GiveWeaponEvent = ReplicatedStorage:WaitForChild("GiveWeapon")
local TeleportKidsEvent = ReplicatedStorage:WaitForChild("TeleportKidsToBase")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Helper to fire teleport (server will authorize)
local function requestTeleportToMouse()
    if not mouse then return end
    local pos = mouse.Hit and mouse.Hit.p
    if pos then
        -- show confirmation modal instead of firing directly
        showTeleportConfirm(pos)
    end
end

local function requestGiveWeapon(name)
    GiveWeaponEvent:FireServer(name)
end

local function requestTeleportKids()
    TeleportKidsEvent:FireServer()
end

-- Default weapon to give if you press the hotkey. Edit to match one of your Tools.
local DEFAULT_WEAPON = "Sword"

-- Hotkeys: T = teleport, K = give default weapon, Y = teleport kids
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        requestTeleportToMouse()
    elseif input.KeyCode == Enum.KeyCode.K then
        -- use the textbox value
        local name = weaponBox.Text or DEFAULT_WEAPON
        if name ~= "" then requestGiveWeapon(name) end
    elseif input.KeyCode == Enum.KeyCode.Y then
        requestTeleportKids()
    end
end)

-- Simple on-screen developer button and panel (created at runtime)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevAdminGUI"
screenGui.ResetOnSpawn = true
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Toggle button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 48, 0, 48)
toggleButton.Position = UDim2.new(0, 8, 0, 8)
toggleButton.Text = "⚙"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 22
toggleButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleButton.TextColor3 = Color3.fromRGB(220,220,220)
toggleButton.Parent = screenGui
local uCorner = Instance.new("UICorner", toggleButton)
uCorner.CornerRadius = UDim.new(0,8)

-- Panel
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 260, 0, 180)
panel.Position = UDim2.new(0, 8, 0, 64)
panel.Visible = false
panel.BackgroundColor3 = Color3.fromRGB(40,40,40)
panel.BackgroundTransparency = 0
panel.BorderSizePixel = 0
panel.Parent = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 30)
title.Position = UDim2.new(0, 8, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Developer Controls"
title.TextColor3 = Color3.fromRGB(240,240,240)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

-- Weapon input box
local weaponBox = Instance.new("TextBox")
weaponBox.Name = "WeaponBox"
weaponBox.Size = UDim2.new(0, 180, 0, 30)
weaponBox.Position = UDim2.new(0, 8, 0, 48)
weaponBox.Text = DEFAULT_WEAPON
weaponBox.PlaceholderText = "Weapon name (e.g. Sword)"
weaponBox.ClearTextOnFocus = false
weaponBox.Parent = panel
weaponBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
weaponBox.TextColor3 = Color3.fromRGB(240,240,240)
Instance.new("UICorner", weaponBox).CornerRadius = UDim.new(0,6)

local giveBtn = Instance.new("TextButton")
giveBtn.Name = "GiveBtn"
giveBtn.Size = UDim2.new(0, 60, 0, 30)
giveBtn.Position = UDim2.new(0, 196, 0, 48)
giveBtn.Text = "Give"
giveBtn.Parent = panel
giveBtn.BackgroundColor3 = Color3.fromRGB(80,140,80)
giveBtn.TextColor3 = Color3.fromRGB(240,240,240)
Instance.new("UICorner", giveBtn).CornerRadius = UDim.new(0,6)
giveBtn.MouseButton1Click:Connect(function()
    local name = weaponBox.Text or DEFAULT_WEAPON
    if name ~= "" then requestGiveWeapon(name) end
end)

-- Teleport button
local tpBtn = Instance.new("TextButton")
tpBtn.Name = "TPBtn"
tpBtn.Size = UDim2.new(0, 244, 0, 30)
tpBtn.Position = UDim2.new(0, 8, 0, 92)
tpBtn.Text = "Teleport To Mouse (T)"
tpBtn.Parent = panel
tpBtn.BackgroundColor3 = Color3.fromRGB(80,80,160)
tpBtn.TextColor3 = Color3.fromRGB(240,240,240)
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,6)
tpBtn.MouseButton1Click:Connect(requestTeleportToMouse)

-- Teleport Kids button
local kidsBtn = Instance.new("TextButton")
kidsBtn.Name = "KidsBtn"
kidsBtn.Size = UDim2.new(0, 244, 0, 30)
kidsBtn.Position = UDim2.new(0, 8, 0, 132)
kidsBtn.Text = "Teleport All Kids To Base (Y)"
kidsBtn.Parent = panel
kidsBtn.BackgroundColor3 = Color3.fromRGB(140,80,80)
kidsBtn.TextColor3 = Color3.fromRGB(240,240,240)
Instance.new("UICorner", kidsBtn).CornerRadius = UDim.new(0,6)
kidsBtn.MouseButton1Click:Connect(requestTeleportKids)

toggleButton.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

-- Make the panel draggable
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragInput, dragStart, startPos

local function clampToViewport(pos, size)
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    local x = math.clamp(pos.X, 0, viewport.X - size.X)
    local y = math.clamp(pos.Y, 0, viewport.Y - size.Y)
    return Vector2.new(x, y)
end

local function updateDrag(input)
    if not dragging or not dragInput then return end
    local delta = input.Position - dragStart
    local newPos = startPos + delta
    local size = Vector2.new(panel.AbsoluteSize.X, panel.AbsoluteSize.Y)
    local clamped = clampToViewport(newPos, size)
    panel.Position = UDim2.new(0, clamped.X, 0, clamped.Y)
end

panel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Vector2.new(panel.AbsolutePosition.X, panel.AbsolutePosition.Y)
        dragInput = input
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

panel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(updateDrag)

-- Add small icons (text-based) to buttons for quick recognition
local function addIconTo(button, iconText)
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.Position = UDim2.new(0, 8, 0, (button.Position.Y.Offset - 8))
    icon.BackgroundTransparency = 1
    icon.Text = iconText
    icon.Font = Enum.Font.SourceSansBold
    icon.TextSize = 18
    icon.TextColor3 = Color3.fromRGB(240,240,240)
    icon.Parent = panel
    return icon
end

-- Place icons next to each control (use simple emoji/text icons)
addIconTo(giveBtn, "🗡")
addIconTo(tpBtn, "📍")
addIconTo(kidsBtn, "👶")


-- Confirmation modal for teleport
local confirmModal = Instance.new("Frame")
confirmModal.Name = "ConfirmModal"
confirmModal.Size = UDim2.new(0, 320, 0, 120)
confirmModal.Position = UDim2.new(0.5, -160, 0.5, -60)
confirmModal.BackgroundColor3 = Color3.fromRGB(25,25,25)
confirmModal.Visible = false
confirmModal.Parent = screenGui
Instance.new("UICorner", confirmModal).CornerRadius = UDim.new(0,8)

local confirmText = Instance.new("TextLabel")
confirmText.Size = UDim2.new(1, -16, 0, 48)
confirmText.Position = UDim2.new(0,8,0,8)
confirmText.BackgroundTransparency = 1
confirmText.TextColor3 = Color3.fromRGB(230,230,230)
confirmText.Text = "Confirm teleport to this location?"
confirmText.Font = Enum.Font.SourceSans
confirmText.TextSize = 16
confirmText.TextWrapped = true
confirmText.TextXAlignment = Enum.TextXAlignment.Left
confirmText.Parent = confirmModal

local confirmBtn = Instance.new("TextButton")
confirmBtn.Size = UDim2.new(0, 140, 0, 32)
confirmBtn.Position = UDim2.new(0, 16, 0, 68)
confirmBtn.Text = "Confirm"
confirmBtn.BackgroundColor3 = Color3.fromRGB(80,140,80)
confirmBtn.TextColor3 = Color3.fromRGB(240,240,240)
Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0,6)
confirmBtn.Parent = confirmModal

local cancelBtn = Instance.new("TextButton")
cancelBtn.Size = UDim2.new(0, 140, 0, 32)
cancelBtn.Position = UDim2.new(0, 164, 0, 68)
cancelBtn.Text = "Cancel"
cancelBtn.BackgroundColor3 = Color3.fromRGB(160,80,80)
cancelBtn.TextColor3 = Color3.fromRGB(240,240,240)
Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0,6)
cancelBtn.Parent = confirmModal

local pendingTeleportPos = nil

local function showTeleportConfirm(pos)
    pendingTeleportPos = pos
    confirmText.Text = string.format("Confirm teleport to: (%.1f, %.1f, %.1f)?", pos.X, pos.Y, pos.Z)
    confirmModal.Visible = true
end

confirmBtn.MouseButton1Click:Connect(function()
    if pendingTeleportPos then
        TeleportEvent:FireServer(pendingTeleportPos)
    end
    pendingTeleportPos = nil
    confirmModal.Visible = false
end)

cancelBtn.MouseButton1Click:Connect(function()
    pendingTeleportPos = nil
    confirmModal.Visible = false
end)

