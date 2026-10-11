-- Aizen-themed local animation hub scaffold for YOUR OWN Roblox experience.
-- Install as a LocalScript in StarterPlayer > StarterPlayerScripts.
-- This does not use executor APIs or HAT reanimation. Animation IDs must be yours
-- (or otherwise authorized) and should be configured below.
-- It only plays animations on the local player's character.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ANIMATIONS = {
    -- Replace 0 with animation asset IDs you own/are authorized to use.
    ["Idle"] = 0,
    ["Pose"] = 0,
    ["Attack"] = 0,
}

local tracks = {}
local currentTrack

local function getAnimator()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    return animator
end

local function stopCurrent()
    if currentTrack then
        pcall(function() currentTrack:Stop(0.15) end)
        currentTrack = nil
    end
end

local function playAnimation(name)
    local id = ANIMATIONS[name]
    if not id or id == 0 then
        warn("[AizenHub] Set a valid authorized animation ID for: " .. name)
        return
    end

    stopCurrent()
    local animator = getAnimator()
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. tostring(id)

    local ok, trackOrError = pcall(function()
        return animator:LoadAnimation(animation)
    end)
    animation:Destroy()

    if not ok then
        warn("[AizenHub] Could not load animation:", trackOrError)
        return
    end

    currentTrack = trackOrError
    currentTrack.Priority = Enum.AnimationPriority.Action
    currentTrack:Play(0.15)
end

local gui = Instance.new("ScreenGui")
gui.Name = "AizenHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(270, 250)
panel.Position = UDim2.new(0, 24, 0.35, 0)
panel.BackgroundColor3 = Color3.fromRGB(13, 12, 20)
panel.BackgroundTransparency = 0.06
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(146, 42, 66)
stroke.Thickness = 1.5
stroke.Transparency = 0.12
stroke.Parent = panel

local header = Instance.new("TextLabel")
header.Name = "Header"
header.Size = UDim2.new(1, -52, 0, 44)
header.Position = UDim2.fromOffset(14, 3)
header.BackgroundTransparency = 1
header.Text = "AIZEN  /  ANIMATION HUB"
header.TextColor3 = Color3.fromRGB(245, 220, 225)
header.Font = Enum.Font.GothamBold
header.TextSize = 14
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = panel

local close = Instance.new("TextButton")
close.Name = "Close"
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -38, 0, 9)
close.BackgroundColor3 = Color3.fromRGB(76, 23, 38)
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 22
close.Font = Enum.Font.GothamBold
close.Parent = panel
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
close.Activated:Connect(function()
    panel.Visible = false
end)

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -28, 0, 24)
subtitle.Position = UDim2.fromOffset(14, 43)
subtitle.BackgroundTransparency = 1
subtitle.Text = "LOCAL COSMETIC CONTROLS"
subtitle.TextColor3 = Color3.fromRGB(181, 112, 128)
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = panel

local function addButton(name, index)
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Size = UDim2.new(1, -28, 0, 42)
    button.Position = UDim2.fromOffset(14, 78 + (index - 1) * 49)
    button.BackgroundColor3 = Color3.fromRGB(42, 20, 31)
    button.AutoButtonColor = true
    button.Text = string.upper(name)
    button.TextColor3 = Color3.fromRGB(245, 230, 234)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Parent = panel
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(116, 43, 63)
    buttonStroke.Transparency = 0.2
    buttonStroke.Parent = button
    button.Activated:Connect(function()
        playAnimation(name)
    end)
end

addButton("Idle", 1)
addButton("Pose", 2)
addButton("Attack", 3)

-- Drag panel with mouse or touch.
local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = panel.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

player.CharacterAdded:Connect(function()
    stopCurrent()
end)
