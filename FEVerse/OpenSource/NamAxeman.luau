-- [[ Nam Axeman : Hat Reanimate / cosmetic moveset ]]
-- Local cosmetic controls only. No remote damage or player-fling behavior.
-- Neck accessory IDs are matched explicitly; the axe accessory follows the right arm.

local Reanimate_Settings = {
    Frequency = 6,
    Amplification = 6,
    FrontOffset = 2.5,
}

local NeckAccessories = {
    ["88886554182275"] = true,
    ["90788603154080"] = true,
    ["120111604252410"] = true,
    ["128893482026011"] = true,
    ["87291559615126"] = true,
}
local AxeAccessoryId = "16471816474"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Rig
local RigHumanoid
local RigRoot
local CharacterHumanoid
local Aligns = {}
local Connections = {}
local MobileGui
local SwingStarted = 0
local SwingDuration = 0.38
local RightShoulder
local ShoulderC0
local destroyed = false

local function assetIdMatches(value, id)
    return value ~= nil and string.find(tostring(value), id, 1, true) ~= nil
end

local function getAssetFields(accessory)
    local fields = { accessory.Name }
    local handle = accessory:FindFirstChild("Handle")
    if not handle then return fields end
    if handle:IsA("MeshPart") then
        table.insert(fields, handle.MeshId)
        table.insert(fields, handle.TextureID)
    end
    for _, object in ipairs(handle:GetDescendants()) do
        if object:IsA("SpecialMesh") then
            table.insert(fields, object.MeshId)
            table.insert(fields, object.TextureId)
        elseif object:IsA("MeshPart") then
            table.insert(fields, object.MeshId)
            table.insert(fields, object.TextureID)
        end
    end
    return fields
end

local function accessoryHasId(accessory, id)
    for _, value in ipairs(getAssetFields(accessory)) do
        if assetIdMatches(value, id) then return true end
    end
    return false
end

local function findPart(model, name)
    return model and (model:FindFirstChild(name, true))
end

local function rebuildAccessoryAligns(character)
    table.clear(Aligns)
    if not character or not Rig then return end
    local rightArm = findPart(Rig, "Right Arm")
    for _, accessory in ipairs(character:GetChildren()) do
        if accessory:IsA("Accessory") or accessory:IsA("Accoutrement") then
            local handle = accessory:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                local targetPart
                local isNeck = false
                for id in pairs(NeckAccessories) do
                    if accessoryHasId(accessory, id) then
                        isNeck = true
                        break
                    end
                end
                if isNeck then
                    targetPart = RigRoot
                elseif accessoryHasId(accessory, AxeAccessoryId) then
                    targetPart = rightArm or RigRoot
                end
                if targetPart then
                    table.insert(Aligns, {
                        Part0 = handle,
                        Part1 = targetPart,
                        Offset = isNeck and CFrame.identity or CFrame.new(0, -0.65, -0.25),
                    })
                end
            end
        end
    end
end

local function swing()
    if not RightShoulder then return end
    SwingStarted = os.clock()
end

local function makeButton(parent, name, label, position, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.AnchorPoint = Vector2.new(1, 1)
    button.Position = position
    button.Size = UDim2.fromOffset(48, 48)
    button.Text = label
    button.TextSize = 15
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(42, 45, 54)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Visible = UserInputService.TouchEnabled
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(190, 190, 200)
    stroke.Thickness = 1.4
    stroke.Parent = button

    button.Activated:Connect(callback)
    return button
end

local function createMobileUI()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    local previous = playerGui:FindFirstChild("AxemanMobileUI")
    if previous then previous:Destroy() end

    MobileGui = Instance.new("ScreenGui")
    MobileGui.Name = "AxemanMobileUI"
    MobileGui.ResetOnSpawn = false
    MobileGui.IgnoreGuiInset = true
    MobileGui.DisplayOrder = 40
    MobileGui.Parent = playerGui

    makeButton(MobileGui, "AxeAttack", "AXE", UDim2.new(1, -24, 1, -145), swing)
    makeButton(MobileGui, "AxeJump", "JUMP", UDim2.new(1, -24, 1, -205), function()
        if RigHumanoid then RigHumanoid.Jump = true end
    end)
end

local function bindCharacter(character)
    Character = character
    CharacterHumanoid = character:WaitForChild("Humanoid", 10)
    if RigRoot and character:FindFirstChild("HumanoidRootPart") then
        RigRoot.CFrame = character.HumanoidRootPart.CFrame
    end
    rebuildAccessoryAligns(character)
end

local function start()
    local description = Instance.new("HumanoidDescription")
    Rig = Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R6)
    Rig.Name = "NamAxeman"
    RigHumanoid = Rig:WaitForChild("Humanoid")
    RigRoot = Rig:WaitForChild("HumanoidRootPart")
    Rig.Parent = Workspace

    for _, object in ipairs(Rig:GetDescendants()) do
        if object:IsA("BasePart") then
            object.CanCollide = false
        end
    end
    RightShoulder = findPart(Rig, "Right Shoulder")
    ShoulderC0 = RightShoulder and RightShoulder.C0

    LocalPlayer.Character = Rig
    bindCharacter(Character)
    table.insert(Connections, LocalPlayer.CharacterAdded:Connect(bindCharacter))

    table.insert(Connections, RunService.PostSimulation:Connect(function()
        if destroyed then return end
        if Rig and RigHumanoid and CharacterHumanoid and CharacterHumanoid.Health > 0 then
            RigHumanoid:Move(CharacterHumanoid.MoveDirection)
            RigHumanoid.Jump = CharacterHumanoid.Jump
        end
        local axis = 27 + math.sin(os.clock())
        for _, align in ipairs(Aligns) do
            local part0, part1 = align.Part0, align.Part1
            if part0 and part1 and part0:IsDescendantOf(Workspace) and part1:IsDescendantOf(Workspace) then
                part0.AssemblyAngularVelocity = Vector3.zero
                part0.AssemblyLinearVelocity = Vector3.new(part1.AssemblyLinearVelocity.X, axis, part1.AssemblyLinearVelocity.Z)
                part0.CFrame = part1.CFrame * align.Offset
            end
        end
        if RightShoulder and ShoulderC0 then
            local elapsed = os.clock() - SwingStarted
            if SwingStarted > 0 and elapsed < SwingDuration then
                local alpha = math.clamp(elapsed / SwingDuration, 0, 1)
                RightShoulder.C0 = ShoulderC0 * CFrame.Angles(math.sin(alpha * math.pi) * math.rad(-100), 0, math.sin(alpha * math.pi) * math.rad(16))
            else
                RightShoulder.C0 = ShoulderC0
                SwingStarted = 0
            end
        end
    end))

    table.insert(Connections, RunService.PreSimulation:Connect(function()
        if Rig then
            for _, part in ipairs(Rig:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end))

    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Q then swing() end
    end))

    createMobileUI()
end

local function cleanup()
    destroyed = true
    for _, connection in ipairs(Connections) do
        pcall(function() connection:Disconnect() end)
    end
    if MobileGui then MobileGui:Destroy() end
    if RightShoulder and ShoulderC0 then RightShoulder.C0 = ShoulderC0 end
    table.clear(Connections)
    table.clear(Aligns)
end

start()
