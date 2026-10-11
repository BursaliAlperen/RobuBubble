-- RobuBubble accessory attachment (server Script)
-- Put this Script in ServerScriptService after running Studio/AccessoryInstaller.lua.
-- Requires ServerStorage/RobuBubbleAccessories to contain imported Accessory instances.
-- No fling, no reanimation, no character joint destruction, no executor-only APIs.

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local CONFIG = {
    FolderName = "RobuBubbleAccessories",
    HeadAccessoryName = "HeadAccessory_134624581597947",
    NeckAccessoryNames = {
        "NeckAccessory_88886554182275",
        "NeckAccessory_90788603154080",
        "NeckAccessory_120111604252410",
        "NeckAccessory_128893482026011",
        "NeckAccessory_87291559615126",
    },
    -- Color detection rules from the requested setup:
    -- grey -> torso, black -> legs, white -> arms.
    -- This detects Handle.BasePart.Color only; textured mesh appearance may differ.
    GreyLuminanceMin = 0.20,
    GreyLuminanceMax = 0.72,
    BlackLuminanceMax = 0.19,
    WhiteLuminanceMin = 0.73,
    -- Local placement offsets are relative to the chosen body part.
    -- Tune these in Studio after previewing the actual mesh geometry.
    Offsets = {
        Torso = CFrame.new(0, 0, -0.45),
        Leg = CFrame.new(0, 0, 0),
        Arm = CFrame.new(0, 0, 0),
    },
}

local function logWarn(message)
    warn("[RobuBubbleAccessories] " .. message)
end

local function getFolder()
    return ServerStorage:FindFirstChild(CONFIG.FolderName)
end

local function getHandle(accessory)
    return accessory and accessory:FindFirstChild("Handle")
end

local function getLuminance(color)
    return 0.2126 * color.R + 0.7152 * color.G + 0.0722 * color.B
end

local function classifyAccessory(accessory)
    local handle = getHandle(accessory)
    if not handle or not handle:IsA("BasePart") then
        return nil, "missing BasePart Handle"
    end
    local c = handle.Color
    local spread = math.max(c.R, c.G, c.B) - math.min(c.R, c.G, c.B)
    local l = getLuminance(c)
    if l <= CONFIG.BlackLuminanceMax then
        return "Leg", nil
    elseif l >= CONFIG.WhiteLuminanceMin then
        return "Arm", nil
    elseif spread <= 0.16 and l >= CONFIG.GreyLuminanceMin and l <= CONFIG.GreyLuminanceMax then
        return "Torso", nil
    end
    return nil, ("Handle.Color is not clearly grey/black/white (RGB %.2f, %.2f, %.2f)"):format(c.R, c.G, c.B)
end

local function targetPart(character, category, accessoryName)
    if category == "Torso" then
        return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    elseif category == "Leg" then
        local side = (tonumber(accessoryName:match("(%d+)$")) or 0) % 2 == 0 and "Left" or "Right"
        return character:FindFirstChild(side .. " Leg") or character:FindFirstChild(side .. "LowerLeg")
    elseif category == "Arm" then
        local side = (tonumber(accessoryName:match("(%d+)$")) or 0) % 2 == 0 and "Left" or "Right"
        return character:FindFirstChild(side .. " Arm") or character:FindFirstChild(side .. "LowerArm")
    end
    return nil
end

local function attachRigidAccessory(character, source, target, offset, uniqueName)
    local handle = getHandle(source)
    if not handle or not handle:IsA("BasePart") then
        logWarn(source.Name .. ": skipped because Handle is missing.")
        return
    end
    local clone = source:Clone()
    clone.Name = uniqueName
    local cloneHandle = getHandle(clone)
    if not cloneHandle or not cloneHandle:IsA("BasePart") then
        clone:Destroy()
        logWarn(source.Name .. ": cloned accessory has no BasePart Handle.")
        return
    end

    -- Preserve all source parts and avoid deleting/rewiring character joints.
    clone.Parent = character
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.CanCollide = false
            part.CanTouch = false
            part.Massless = true
        end
    end
    cloneHandle.CFrame = target.CFrame * offset
    local weld = Instance.new("WeldConstraint")
    weld.Name = "RobuBubbleAccessoryWeld"
    weld.Part0 = target
    weld.Part1 = cloneHandle
    weld.Parent = cloneHandle
end

local function applyAccessories(character)
    local folder = getFolder()
    if not folder then
        logWarn("ServerStorage/" .. CONFIG.FolderName .. " is missing; run the Studio importer first.")
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        logWarn("Character has no Humanoid.")
        return
    end

    local headSource = folder:FindFirstChild(CONFIG.HeadAccessoryName)
    local head = character:FindFirstChild("Head")
    if headSource and head and headSource:IsA("Accessory") then
        local already = character:FindFirstChild("RobuBubble_HeadAccessory")
        if not already then
            local clone = headSource:Clone()
            clone.Name = "RobuBubble_HeadAccessory"
            local ok, err = pcall(function()
                humanoid:AddAccessory(clone)
            end)
            if not ok then
                clone:Destroy()
                logWarn("Could not attach head accessory: " .. tostring(err))
            end
        end
    else
        logWarn("Head accessory or Head part missing; skipped head accessory.")
    end

    for _, accessoryName in ipairs(CONFIG.NeckAccessoryNames) do
        local source = folder:FindFirstChild(accessoryName)
        if not source or not source:IsA("Accessory") then
            logWarn(accessoryName .. " missing from imported folder.")
            continue
        end
        if character:FindFirstChild("RobuBubble_" .. accessoryName) then
            continue
        end
        local category, reason = classifyAccessory(source)
        if not category then
            logWarn(accessoryName .. " not auto-attached: " .. tostring(reason))
            continue
        end
        local target = targetPart(character, category, accessoryName)
        if not target or not target:IsA("BasePart") then
            logWarn(accessoryName .. ": no target body part for " .. category .. ".")
            continue
        end
        local offset = CONFIG.Offsets[category] or CFrame.new()
        attachRigidAccessory(character, source, target, offset, "RobuBubble_" .. accessoryName)
    end
end

local function onPlayer(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(1)
        local ok, err = pcall(applyAccessories, character)
        if not ok then
            logWarn(("Failed for %s: %s"):format(player.Name, tostring(err)))
        end
    end)
    if player.Character then
        task.spawn(function()
            task.wait(1)
            local ok, err = pcall(applyAccessories, player.Character)
            if not ok then
                logWarn(("Failed for %s: %s"):format(player.Name, tostring(err)))
            end
        end)
    end
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    onPlayer(player)
end

print("[RobuBubbleAccessories] Ready. Fling is not included.")
