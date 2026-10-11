--!strict
-- Nam Axeman - R6 cosmetic moveset
-- Local-only visual accessory attachment and arm swing.
-- No remote damage, fling, self-damage, or character replacement.
-- Note: Roblox does not expose a reliable catalog asset ID on every live Accessory.
-- Detection checks SourceAssetId (when available), accessory name, and mesh/texture IDs.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LOCAL_PLAYER = Players.LocalPlayer
local NECK_ACCESSORY_IDS: {[string]: boolean} = {
    ["88886554182275"] = true,
    ["90788603154080"] = true,
    ["120111604252410"] = true,
    ["128893482026011"] = true,
    ["87291559615126"] = true,
}
local AXE_ACCESSORY_ID = "16471816474"
local SWING_DURATION = 0.38
local AXE_OFFSET = CFrame.new(0, -0.65, -0.25)
local NECK_OFFSET = CFrame.identity

local character: Model? = nil
local humanoid: Humanoid? = nil
local shoulder: Motor6D? = nil
local shoulderBaseC0: CFrame? = nil
local swingStartedAt = 0
local updateConnection: RBXScriptConnection? = nil
local inputConnection: RBXScriptConnection? = nil
local characterConnection: RBXScriptConnection? = nil
local accessoryConnections: {RBXScriptConnection} = {}
local createdWelds: {WeldConstraint} = {}
local mobileGui: ScreenGui? = nil
local destroyed = false

local function disconnect(connection: RBXScriptConnection?)
    if connection then
        connection:Disconnect()
    end
end

local function clearAccessoryWelds()
    for _, connection in ipairs(accessoryConnections) do
        connection:Disconnect()
    end
    table.clear(accessoryConnections)

    for _, weld in ipairs(createdWelds) do
        if weld.Parent then
            weld:Destroy()
        end
    end
    table.clear(createdWelds)
end

local function safeSourceAssetId(instance: Instance): string?
    local ok, value = pcall(function()
        return (instance :: any).SourceAssetId
    end)
    if ok and value ~= nil then
        return tostring(value)
    end
    return nil
end

local function accessoryFields(accessory: Accessory): {string}
    local fields = {accessory.Name}
    local sourceId = safeSourceAssetId(accessory)
    if sourceId then
        table.insert(fields, sourceId)
    end

    local handle = accessory:FindFirstChild("Handle")
    if not handle then
        return fields
    end

    local function addProperty(object: Instance, propertyName: string)
        local ok, value = pcall(function()
            return (object :: any)[propertyName]
        end)
        if ok and value ~= nil then
            table.insert(fields, tostring(value))
        end
    end

    addProperty(handle, "MeshId")
    addProperty(handle, "TextureID")
    for _, descendant in ipairs(handle:GetDescendants()) do
        if descendant:IsA("SpecialMesh") then
            addProperty(descendant, "MeshId")
            addProperty(descendant, "TextureId")
        elseif descendant:IsA("MeshPart") then
            addProperty(descendant, "MeshId")
            addProperty(descendant, "TextureID")
        end
    end
    return fields
end

local function accessoryMatches(accessory: Accessory, id: string): boolean
    for _, field in ipairs(accessoryFields(accessory)) do
        if string.find(field, id, 1, true) then
            return true
        end
    end
    return false
end

local function findBodyPart(model: Model, names: {string}): BasePart?
    for _, name in ipairs(names) do
        local part = model:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

local function weldAccessory(accessory: Accessory, target: BasePart, offset: CFrame)
    local handle = accessory:FindFirstChild("Handle")
    if not handle or not handle:IsA("BasePart") then
        warn("[Nam Axeman] Accessory has no BasePart Handle:", accessory.Name)
        return
    end

    for _, descendant in ipairs(handle:GetChildren()) do
        if descendant:IsA("Weld") or descendant:IsA("WeldConstraint") or descendant:IsA("Motor6D") then
            descendant:Destroy()
        end
    end

    handle.Anchored = false
    handle.CanCollide = false
    handle.CanTouch = false
    handle.CanQuery = false
    handle.Massless = true
    handle.CFrame = target.CFrame * offset

    local weld = Instance.new("WeldConstraint")
    weld.Name = "NamAxemanAccessoryWeld"
    weld.Part0 = target
    weld.Part1 = handle
    weld.Parent = handle
    table.insert(createdWelds, weld)
end

local function attachKnownAccessories(model: Model)
    clearAccessoryWelds()

    local torso = findBodyPart(model, {"Torso", "UpperTorso", "HumanoidRootPart"})
    local rightArm = findBodyPart(model, {"Right Arm", "RightHand", "RightLowerArm"})
    if not torso then
        warn("[Nam Axeman] Could not find torso/root part.")
        return
    end

    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Accessory") then
            local isNeckAccessory = false
            for id in pairs(NECK_ACCESSORY_IDS) do
                if accessoryMatches(child, id) then
                    isNeckAccessory = true
                    break
                end
            end

            if isNeckAccessory then
                weldAccessory(child, torso, NECK_OFFSET)
            elseif accessoryMatches(child, AXE_ACCESSORY_ID) then
                weldAccessory(child, rightArm or torso, AXE_OFFSET)
            end
        end
    end

    table.insert(accessoryConnections, model.ChildAdded:Connect(function(child)
        if child:IsA("Accessory") then
            task.defer(function()
                if destroyed or not model.Parent then
                    return
                end
                local isNeckAccessory = false
                for id in pairs(NECK_ACCESSORY_IDS) do
                    if accessoryMatches(child, id) then
                        isNeckAccessory = true
                        break
                    end
                end
                if isNeckAccessory then
                    weldAccessory(child, torso, NECK_OFFSET)
                elseif accessoryMatches(child, AXE_ACCESSORY_ID) then
                    weldAccessory(child, rightArm or torso, AXE_OFFSET)
                end
            end)
        end
    end))
end

local function swing()
    if not shoulder or not shoulderBaseC0 then
        return
    end
    swingStartedAt = os.clock()
end

local function makeRoundButton(parent: Instance, name: string, label: string, position: UDim2, callback: () -> ())
    local button = Instance.new("TextButton")
    button.Name = name
    button.AnchorPoint = Vector2.new(1, 1)
    button.Position = position
    button.Size = UDim2.fromOffset(50, 50)
    button.Text = label
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(38, 42, 51)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Visible = UserInputService.TouchEnabled
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(190, 198, 210)
    stroke.Thickness = 1.25
    stroke.Parent = button

    button.Activated:Connect(callback)
    return button
end

local function buildMobileUI()
    local playerGui = LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        return
    end

    local oldGui = playerGui:FindFirstChild("NamAxemanMobileUI")
    if oldGui then
        oldGui:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "NamAxemanMobileUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 40
    gui.Parent = playerGui
    mobileGui = gui

    makeRoundButton(gui, "AxeAttack", "AXE · Q", UDim2.new(1, -22, 1, -142), swing)
    makeRoundButton(gui, "AxeJump", "JUMP", UDim2.new(1, -22, 1, -202), function()
        if humanoid and humanoid.Health > 0 then
            humanoid.Jump = true
        end
    end)
end

local function bindCharacter(newCharacter: Model)
    clearAccessoryWelds()
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid", 10) :: Humanoid?
    shoulder = nil
    shoulderBaseC0 = nil
    swingStartedAt = 0

    if humanoid then
        local torso = findBodyPart(newCharacter, {"Torso"})
        if torso then
            local motor = torso:FindFirstChild("Right Shoulder")
            if motor and motor:IsA("Motor6D") then
                shoulder = motor
                shoulderBaseC0 = motor.C0
            end
        end
    end

    attachKnownAccessories(newCharacter)
end

local function cleanup()
    if destroyed then
        return
    end
    destroyed = true
    disconnect(updateConnection)
    disconnect(inputConnection)
    disconnect(characterConnection)
    clearAccessoryWelds()

    if shoulder and shoulderBaseC0 and shoulder.Parent then
        shoulder.C0 = shoulderBaseC0
    end
    if mobileGui then
        mobileGui:Destroy()
        mobileGui = nil
    end
end

local function start()
    local currentCharacter = LOCAL_PLAYER.Character or LOCAL_PLAYER.CharacterAdded:Wait()
    bindCharacter(currentCharacter)
    buildMobileUI()

    characterConnection = LOCAL_PLAYER.CharacterAdded:Connect(function(newCharacter)
        if not destroyed then
            bindCharacter(newCharacter)
        end
    end)

    inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed or destroyed then
            return
        end
        if input.KeyCode == Enum.KeyCode.Q then
            swing()
        elseif input.KeyCode == Enum.KeyCode.Space and UserInputService.TouchEnabled then
            if humanoid and humanoid.Health > 0 then
                humanoid.Jump = true
            end
        end
    end)

    updateConnection = RunService.PreSimulation:Connect(function()
        if destroyed or not shoulder or not shoulderBaseC0 then
            return
        end

        local elapsed = os.clock() - swingStartedAt
        if swingStartedAt > 0 and elapsed < SWING_DURATION then
            local alpha = math.clamp(elapsed / SWING_DURATION, 0, 1)
            local curve = math.sin(alpha * math.pi)
            shoulder.C0 = shoulderBaseC0 * CFrame.Angles(math.rad(-100) * curve, 0, math.rad(16) * curve)
        else
            shoulder.C0 = shoulderBaseC0
            swingStartedAt = 0
        end
    end)

    script.Destroying:Connect(cleanup)
end

start()
