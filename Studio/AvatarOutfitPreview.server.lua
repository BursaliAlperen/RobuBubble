-- RobuBubble avatar outfit preview (normal Roblox Studio server Script)
-- Put this Script in ServerScriptService in your own experience.
-- Creates a stationary, non-colliding preview rig from the player's CURRENT
-- applied HumanoidDescription, including accessories already worn by the avatar.
-- This is an outfit preview only: it does not reanimate, control, break joints,
-- move, or replace the player's character. No executor-only APIs are used.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local PREVIEW_PREFIX = "RobuBubble_OutfitPreview_"
local OFFSET = CFrame.new(5, 0, 0)

local function removeOldPreview(player)
    local old = Workspace:FindFirstChild(PREVIEW_PREFIX .. player.UserId)
    if old then
        old:Destroy()
    end
end

local function makePreview(player, character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not humanoid or not root or not root:IsA("BasePart") then
        warn("[RobuBubble Outfit Preview] Character is missing Humanoid or HumanoidRootPart for " .. player.Name)
        return
    end
    if player.Character ~= character then
        return
    end

    removeOldPreview(player)

    local descriptionOk, description = pcall(function()
        return humanoid:GetAppliedDescription()
    end)
    if not descriptionOk or not description then
        warn("[RobuBubble Outfit Preview] Could not read the applied avatar description for " .. player.Name)
        return
    end

    local modelOk, preview = pcall(function()
        return Players:CreateHumanoidModelFromDescriptionAsync(description, humanoid.RigType)
    end)
    description:Destroy()
    if not modelOk or not preview then
        warn("[RobuBubble Outfit Preview] Could not create preview rig for " .. player.Name .. ": " .. tostring(preview))
        return
    end
    if player.Character ~= character then
        preview:Destroy()
        return
    end

    preview.Name = PREVIEW_PREFIX .. player.UserId
    preview:SetAttribute("PreviewOfUserId", player.UserId)
    preview.Parent = Workspace

    -- Keep the preview passive and out of gameplay physics.
    for _, descendant in ipairs(preview:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CanCollide = false
            descendant.CanTouch = false
            descendant.CanQuery = false
        end
    end

    local previewRoot = preview:FindFirstChild("HumanoidRootPart")
    if previewRoot and previewRoot:IsA("BasePart") then
        previewRoot.Anchored = true
    end
    preview:PivotTo(root.CFrame * OFFSET)
end

local function queuePreviewAfterAppearance(player, character)
    local finished = false
    local appearanceConnection

    local function runOnce()
        if finished then
            return
        end
        finished = true
        if appearanceConnection then
            appearanceConnection:Disconnect()
        end
        if player.Character == character then
            task.spawn(makePreview, player, character)
        end
    end

    appearanceConnection = player.CharacterAppearanceLoaded:Connect(function(loadedCharacter)
        if loadedCharacter == character then
            runOnce()
        end
    end)

    -- CharacterAppearanceLoaded can have fired before this Script starts.
    -- The bounded fallback still supports already-loaded characters.
    task.delay(8, runOnce)
end

local function connectPlayer(player)
    player.CharacterAdded:Connect(function(character)
        queuePreviewAfterAppearance(player, character)
    end)

    if player.Character then
        queuePreviewAfterAppearance(player, player.Character)
    end
end

Players.PlayerAdded:Connect(connectPlayer)
Players.PlayerRemoving:Connect(removeOldPreview)

for _, player in ipairs(Players:GetPlayers()) do
    connectPlayer(player)
end

print("[RobuBubble Outfit Preview] Ready. Uses the currently applied avatar outfit; no reanimation or fling.")
