-- HatCosmetic.client.lua
-- Safe, self-only accessory visual controller for a Roblox experience.
-- Install as a LocalScript in StarterPlayer > StarterPlayerScripts.
-- This is NOT executor HAT reanimation: it does not replace the character,
-- alter network ownership, create fling forces, or affect other players.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("HatCosmeticUI")
if oldGui then oldGui:Destroy() end

local enabled = false
local highlights = {}
local characterConnection
local descendantConnection

local function clearHighlights()
    for accessory, highlight in pairs(highlights) do
        if highlight then
            highlight:Destroy()
        end
        highlights[accessory] = nil
    end
end

local function applyAccessory(accessory)
    if not enabled or not accessory:IsA("Accessory") or highlights[accessory] then
        return
    end
    local handle = accessory:FindFirstChild("Handle")
    if not handle or not handle:IsA("BasePart") then
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "LocalHatCosmeticHighlight"
    highlight.Adornee = accessory
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillColor = Color3.fromRGB(160, 45, 75)
    highlight.FillTransparency = 0.72
    highlight.OutlineColor = Color3.fromRGB(255, 205, 220)
    highlight.OutlineTransparency = 0.05
    highlight.Parent = accessory
    highlights[accessory] = highlight
end

local function bindCharacter(character)
    clearHighlights()
    if descendantConnection then
        descendantConnection:Disconnect()
        descendantConnection = nil
    end
    if not character then return end

    if enabled then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Accessory") then applyAccessory(child) end
        end
    end

    descendantConnection = character.ChildAdded:Connect(function(child)
        if child:IsA("Accessory") then
            task.defer(function()
                if child.Parent == character then applyAccessory(child) end
            end)
        end
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "HatCosmeticUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.Name = "Toggle"
button.Size = UDim2.fromOffset(176, 42)
button.Position = UDim2.new(0, 20, 0.58, 0)
button.BackgroundColor3 = Color3.fromRGB(37, 19, 29)
button.TextColor3 = Color3.fromRGB(255, 230, 238)
button.Font = Enum.Font.GothamBold
button.TextSize = 12
button.Text = "HAT VISUALS: OFF"
button.AutoButtonColor = true
button.Parent = gui
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(160, 45, 75)
stroke.Thickness = 1.5
stroke.Parent = button

button.Activated:Connect(function()
    enabled = not enabled
    button.Text = enabled and "HAT VISUALS: ON" or "HAT VISUALS: OFF"
    button.BackgroundColor3 = enabled and Color3.fromRGB(83, 25, 48) or Color3.fromRGB(37, 19, 29)
    bindCharacter(player.Character)
end)

characterConnection = player.CharacterAdded:Connect(bindCharacter)
if player.Character then bindCharacter(player.Character) end

gui.Destroying:Connect(function()
    enabled = false
    clearHighlights()
    if characterConnection then characterConnection:Disconnect() end
    if descendantConnection then descendantConnection:Disconnect() end
end)
