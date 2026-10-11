--[[ 
    ============================================================================
    PROJECT: PEGAMUX JOHN DOE ULTIMATE REANIMATE SUITE (V8 - ANIM.JSON NATIVE)
    VERSION: 8.0.0-EXTRACTED-ANIMS
    AUTHOR: Pegamux
    
    DESCRIPTION:
    A comprehensive, single-file Roblox reanimation system tailored for B3 Inventory.
    
    KEY FEATURES:
    1. NATIVE .ANIM SUPPORT: Downloads JSON-based animation data directly from GitHub.
       No more heavy RBXM files. Faster loading, smaller footprint.
    2. AUTO-REANIMATE INITIATOR: Instantly breaks joints and spawns an invisible R6 rig.
    3. HAT LOCKING PHYSICS: Real-time CFrame locking for Head and Neck accessories.
       Ensures hats stay glued to the body during flings and movements.
    4. FULL COMBAT SYSTEM: Includes Slash, Corrupt Energy, Digital Footprint, 
       Stunned states, and all Execution variants (Default, Milestone4, Legacy, Screamer).
    5. MOBILE OPTIMIZED UI: Large touch-friendly buttons for Attack, Ability, and Sprint.
    6. ROBUST LOADING SCREEN: Visual progress bar tracking each downloaded asset.
    
    TARGET REPO STRUCTURE:
    https://github.com/BursaliAlperen/RobuBubble/tree/main/Anims/Extracted
    ├── Idle.anim
    ├── Walk.anim
    ├── Sprint.anim
    ├── Slash.anim
    ├── Corrupt_Energy.anim
    ├── Digital_Footprint.anim
    ├── Stunned_Start.anim
    ├── Stunned_Loop.anim
    ├── Stunned_End.anim
    ├── Execution_KillerRig.anim
    ├── Execution_PlayerRig.anim
    ├── KillerExecution_Default.anim
    ├── VictimExecution_Default.anim
    ├── KillerExecution_Milestone4.anim
    ├── VictimExecution_Milestone4Legacy.anim -- Note: Mismatch in source list handled gracefully
    ├── KillerExecution_Milestone4Legacy.anim
    ├── KillerExecution_Screamer.anim
    └── VictimExecution_Screamer.anim
    ============================================================================
]]

-- ============================================================================
-- SECTION 1: CONFIGURATION CENTER
-- All customizable values are centralized here for easy editing.
-- ============================================================================

local Config = {
    -- [URLS] Base URL for raw content fetching from GitHub
    GithubBaseURL = "https://raw.githubusercontent.com/BursaliAlperen/RobuBubble/main/",
    
    -- [PATHS] Local storage paths within the executor's workspace
    Paths = {
        Root = "Pegamux_JohnDoe_v8/",
        Anims = "Pegamux_JohnDoe_v8/Anims/",
        Sounds = "Pegamux_JohnDoe_v8/Sounds/"
    },
    
    -- [ASSETS] Specific IDs and File Mappings
    Assets = {
        -- The specific Head Accessory ID that replaces the default head visual
        -- This hat will be locked strictly to the Head part of the rig.
        HeadReplacementID = 134624581597947,
        
        -- Mapping of Neck Accessories by Color -> Body Part Target
        -- Keys are Asset IDs, Values are strings representing target parts
        -- Supported Targets: "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"
        NeckAccessoriesMap = {
            [88886554182275] = "Torso",      -- Grey Item 1 -> Chest
            [128893482026011] = "Torso",     -- Grey Item 2 -> Chest (Alt)
            [90788603154080] = "LeftLeg",    -- Black Item 1 -> Left Leg
            [87291559615126] = "RightLeg",   -- Black Item 2 -> Right Leg
            [120111604252410] = "LeftArm",   -- White Item 1 -> Left Arm
        },
        
        -- Remote Files to Download (Relative to GithubBaseURL)
        -- Using the new .anim format provided by user
        AnimationFiles = {
            ["Idle"] = "Anims/Extracted/Idle.anim",
            ["Walk"] = "Anims/Extracted/Walk.anim",
            ["Sprint"] = "Anims/Extracted/Sprint.anim",
            ["Slash"] = "Anims/Extracted/Slash.anim",
            ["Corrupt_Energy"] = "Anims/Extracted/Corrupt_Energy.anim",
            ["Digital_Footprint"] = "Anims/Extracted/Digital_Footprint.anim",
            ["Stunned_Start"] = "Anims/Extracted/Stunned_Start.anim",
            ["Stunned_Loop"] = "Anims/Extracted/Stunned_Loop.anim",
            ["Stunned_End"] = "Anims/Extracted/Stunned_End.anim",
            ["Execution_KillerRig"] = "Anims/Extracted/Execution_KillerRig.anim",
            ["Execution_PlayerRig"] = "Anims/Extracted/Execution_PlayerRig.anim",
            ["KillerExecution_Default"] = "Anims/Extracted/KillerExecution_Default.anim",
            ["VictimExecution_Default"] = "Anims/Extracted/VictimExecution_Default.anim",
            ["KillerExecution_Milestone4"] = "Anims/Extracted/KillerExecution_Milestone4.anim",
            ["VictimExecution_Milestone4Legacy"] = "Anims/Extracted/VictimExecution_Milestone4Legacy.anim",
            ["KillerExecution_Milestone4Legacy"] = "Anims/Extracted/KillerExecution_Milestone4Legacy.anim",
            ["KillerExecution_Screamer"] = "Anims/Extracted/KillerExecution_Screamer.anim",
            ["VictimExecution_Screamer"] = "Anims/Extracted/VictimExecution_Screamer.anim"
        },
        
        -- Sound Files (Assuming these still exist or can be added later)
        SoundFiles = {
            ["Slash"] = "Sounds/Slash.mp3",
            ["Hit"] = "Sounds/Hit.mp3",
            ["Energy"] = "Sounds/Energy.mp3",
            ["Stomp"] = "Sounds/Stomp.mp3",
            ["Kill"] = "Sounds/Kill.mp3",
            ["Step"] = "Sounds/Step.mp3"
        }
    },
    
    -- [PHYSICS] Tuning parameters for the reanimation engine
    Physics = {
        OscillationFrequency = 6,       -- Speed of the sine wave jitter
        OscillationAmplitude = 6,       -- Magnitude of the sine wave jitter
        FrontOffsetDistance = 2.5,      -- Distance camera/player is ahead during prediction
        BreakJointsDelay = 0.255,       -- Delay before breaking joints on respawn
        SimulationRadiusMax = 2147483647, -- Max simulation radius for network replication
        TeleportRandomRange = 12,       -- Random offset range when teleporting after death
        FlingForceMultiplier = 16384,   -- Velocity applied during flings
        AntiSleepStrength = 0.0015,     -- Micro-offset to prevent part sleeping
        GravityCompensationFactor = 27  -- Factor to counteract gravity on aligned parts
    },
    
    -- [GAMEPLAY] Combat and Movement Settings
    Gameplay = {
        WalkSpeedNormal = 9,
        WalkSpeedRun = 27.25,
        JumpPower = 50,
        AttackCooldown = 0.5,           -- Seconds between basic attacks
        AbilityCooldown = 1.5,          -- Seconds between special abilities
        KillAnimationDuration = 2.0,    -- Estimated time for kill animations
        CameraFOVDefault = 80,
        CameraFOVZoomed = 90
    },
    
    -- [DEBUG] Logging settings
    Debug = {
        EnableConsoleLogging = true,
        LogLevel = "INFO"               -- "ERROR", "WARN", "INFO", "DEBUG"
    }
}

-- ============================================================================
-- SECTION 2: SERVICES AND GLOBAL REFERENCES
-- Caching services to avoid repeated lookups improves performance.
-- ============================================================================

local Services = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    Debris = game:GetService("Debris"),
    StarterGui = game:GetService("StarterGui"),
    Lighting = game:GetService("Lighting"),
    SoundService = game:GetService("SoundService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Services.Workspace.CurrentCamera

-- Utility Functions
local function Log(message, level)
    if not Config.Debug.EnableConsoleLogging then return end
    
    local timestamp = os.date("%H:%M:%S")
    local prefix = "[PEGAMUX]"
    local logLevel = level or "INFO"
    
    -- Filter based on configured log level
    local levels = { ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4 }
    local currentThreshold = levels[Config.Debug.LogLevel] or 3
    local messagePriority = levels[logLevel] or 3
    
    if messagePriority <= currentThreshold then
        print(string.format("%s %s [%s]: %s", prefix, timestamp, logLevel, tostring(message)))
    end
end

local function EnsureFolder(path)
    if not isfile(path) then
        makefolder(path)
        Log("Created folder: " .. path, "DEBUG")
    end
end

-- Initialize Directory Structure
EnsureFolder(Config.Paths.Root)
EnsureFolder(Config.Paths.Anims)
EnsureFolder(Config.Paths.Sounds)

-- ============================================================================
-- SECTION 3: LOADING SCREEN MANAGER
-- Creates a robust UI overlay that displays progress while assets download.
-- ============================================================================

local LoadingScreen = {}
LoadingScreen.Gui = nil
LoadingScreen.StatusText = nil
LoadingScreen.CounterText = nil
LoadingScreen.ProgressFill = nil
LoadingScreen.IsVisible = false

function LoadingScreen:Initialize()
    Log("Initializing Loading Screen...", "DEBUG")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Pegamux_LoadingScreen"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 1000 -- Keep it on top
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    self.Gui = screenGui
    
    -- Background Overlay (Darkens the whole screen slightly)
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.BorderSizePixel = 0
    background.Parent = screenGui
    
    -- Central Container
    local container = Instance.new("Frame")
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.Size = UDim2.new(0, 400, 0, 200)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BackgroundTransparency = 0.1
    container.BorderSizePixel = 0
    container.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container
    
    -- Title Text
    local title = Instance.new("TextLabel")
    title.Text = "PEGAMUX JOHN DOE SYSTEM"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Parent = container
    
    -- Status Message ("Downloading Assets...")
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Text = "Preparing System..."
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 16
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 60)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = container
    self.StatusText = statusLabel
    
    -- Progress Bar Container
    local barContainer = Instance.new("Frame")
    barContainer.Size = UDim2.new(1, -40, 0, 20)
    barContainer.Position = UDim2.new(0, 20, 0, 90)
    barContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    barContainer.BorderSizePixel = 0
    barContainer.Parent = container
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 5)
    barCorner.Parent = barContainer
    
    -- Progress Fill (The moving part)
    local fill = Instance.new("Frame")
    fill.Name = "ProgressFill"
    fill.Size = UDim2.new(0, 0, 1, 0) -- Starts at width 0
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 100) -- Greenish neon
    fill.BorderSizePixel = 0
    fill.Parent = barContainer
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = fill
    
    self.ProgressBar = barContainer
    self.ProgressFill = fill
    
    -- Counter Text ("3 / 8 Files")
    local counterLabel = Instance.new("TextLabel")
    counterLabel.Name = "CounterLabel"
    counterLabel.Text = "0 / 0"
    counterLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    counterLabel.Font = Enum.Font.Code
    counterLabel.TextSize = 14
    counterLabel.Size = UDim2.new(1, -20, 0, 20)
    counterLabel.Position = UDim2.new(0, 10, 0, 120)
    counterLabel.BackgroundTransparency = 1
    counterLabel.TextXAlignment = Enum.TextXAlignment.Center
    counterLabel.Parent = container
    self.CounterText = counterLabel
    
    -- Subtext for details
    local detailLabel = Instance.new("TextLabel")
    detailLabel.Name = "DetailLabel"
    detailLabel.Text = ""
    detailLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    detailLabel.Font = Enum.Font.Gotham
    detailLabel.TextSize = 12
    detailLabel.Size = UDim2.new(1, -20, 0, 15)
    detailLabel.Position = UDim2.new(0, 10, 0, 145)
    detailLabel.BackgroundTransparency = 1
    detailLabel.TextXAlignment = Enum.TextXAlignment.Center
    detailLabel.Parent = container
    self.DetailText = detailLabel
    
    self.IsVisible = true
end

function LoadingScreen:SetStatus(text)
    if self.StatusText then
        self.StatusText.Text = text
    end
end

function LoadingScreen:SetCounter(current, total)
    if self.CounterText then
        self.CounterText.Text = string.format("%d / %d", current, total)
    end
end

function LoadingScreen:SetProgress(percent)
    if self.ProgressFill then
        -- Clamp percent between 0 and 1
        percent = math.clamp(percent, 0, 1)
        self.ProgressFill.Size = UDim2.new(percent, 0, 1, 0)
    end
end

function LoadingScreen:SetDetail(text)
    if self.DetailText then
        self.DetailText.Text = text
    end
end

function LoadingScreen:Hide()
    if self.Gui then
        self.Gui:Destroy()
        self.IsVisible = false
        Log("Loading Screen Hidden.", "DEBUG")
    end
end

-- ============================================================================
-- SECTION 4: ASSET MANAGER (DOWNLOAD & CACHE)
-- Handles downloading files from GitHub Raw URLs and caching them locally.
-- Integrates directly with the LoadingScreen for feedback.
-- Now supports .anim (JSON) parsing natively.
-- ============================================================================

local AssetManager = {}
AssetManager.Cache = {} -- Stores loaded instances/assets by key
AssetManager.TotalFiles = 0
AssetManager.DownloadedCount = 0
AssetManager.ParsedAnimations = {} -- Stores decoded animation tables

function AssetManager:CalculateTotalFiles()
    local count = 0
    -- Count Animation Packs (.anim files)
    for _ in pairs(Config.Assets.AnimationFiles) do
        count += 1
    end
    -- Count Sound Files
    for _ in pairs(Config.Assets.SoundFiles) do
        count += 1
    end
    self.TotalFiles = count
    Log("Calculated Total Assets: " .. count, "DEBUG")
end

function AssetManager:DownloadFile(remoteRelativePath, localDirectory, fileName)
    local remoteUrl = Config.GithubBaseURL .. remoteRelativePath
    local localPath = localDirectory .. fileName
    
    -- Update UI Feedback BEFORE attempting download
    LoadingScreen:SetStatus("Downloading: " .. fileName)
    LoadingScreen:SetDetail(remoteUrl)
    
    if isfile(localPath) then
        Log("File already exists (Cached): " .. fileName, "DEBUG")
        self.DownloadedCount += 1
        self:_UpdateProgressUI()
        return localPath
    end
    
    Log("Attempting Download: " .. fileName, "INFO")
    
    local success, errorMsg = pcall(function()
        local response = game:HttpGet(remoteUrl)
        if response then
            writefile(localPath, response)
        else
            error("Empty response from server")
        end
    end)
    
    if success then
        Log("Successfully downloaded: " .. fileName, "INFO")
        self.DownloadedCount += 1
        self:_UpdateProgressUI()
        return localPath
    else
        Log("Failed to download " .. fileName .. ": " .. tostring(errorMsg), "ERROR")
        LoadingScreen:SetStatus("ERROR: Failed to download " .. fileName)
        LoadingScreen:SetDetail(tostring(errorMsg))
        return nil
    end
end

function AssetManager:_UpdateProgressUI()
    local percent = self.DownloadedCount / self.TotalFiles
    LoadingScreen:SetProgress(percent)
    LoadingScreen:SetCounter(self.DownloadedCount, self.TotalFiles)
end

-- NEW FUNCTION: Parse .anim file (Expected to be JSON)
function AssetManager:ParseAnimFile(localFilePath, animName)
    if self.ParsedAnimations[animName] then
        return self.ParsedAnimations[animName]
    end
    
    if not isfile(localFilePath) then
        Log("Anim file missing: " .. localFilePath, "ERROR")
        return nil
    end
    
    LoadingScreen:SetStatus("Parsing Animation: " .. animName)
    
    local success, content = pcall(readfile, localFilePath)
    if not success or not content then
        Log("Failed to read file: " .. localFilePath, "ERROR")
        return nil
    end
    
    -- Attempt to decode JSON
    local decodeSuccess, jsonData = pcall(function()
        return game:GetService("HttpService"):JSONDecode(content)
    end)
    
    if decodeSuccess and jsonData then
        self.ParsedAnimations[animName] = jsonData
        Log("Parsed Animation Data: " .. animName, "DEBUG")
        return jsonData
    else
        Log("Failed to parse JSON for: " .. animName, "ERROR")
        return nil
    end
end

function AssetManager:PrepareAllAssets()
    Log("--- Starting Asset Preparation ---", "INFO")
    
    self:CalculateTotalFiles()
    LoadingScreen:SetCounter(0, self.TotalFiles)
    LoadingScreen:SetProgress(0)
    
    -- Download Animation Packages (.anim)
    for animName, relativePath in pairs(Config.Assets.AnimationFiles) do
        local fileName = relativePath:match("[^/]+$")
        local localPath = self:DownloadFile(relativePath, Config.Paths.Anims, fileName)
        if localPath then
            -- Immediately parse after download to save memory/time later
            self:ParseAnimFile(localPath, animName)
        end
    end
    
    -- Download Sound Effects
    for soundName, relativePath in pairs(Config.Assets.SoundFiles) do
        local fileName = relativePath:match("[^/]+$")
        self:DownloadFile(relativePath, Config.Paths.Sounds, fileName)
    end
    
    Log("--- Asset Preparation Complete ---", "INFO")
    LoadingScreen:SetStatus("System Ready! Launching...")
    task.wait(1) -- Small delay to show completion
    
    return self.ParsedAnimations
end

-- ============================================================================
-- SECTION 5: SOUND MANAGER
-- Manages playback of downloaded MP3 files with volume/pitch controls.
-- ============================================================================

local SoundManager = {}
SoundManager.Instances = {} -- Cache for cloned sounds to prevent GC issues

function SoundManager:Play(soundKey, parentPart, volumeOverride, pitchOverride)
    local filePath = Config.Paths.Sounds .. soundKey .. ".mp3"
    
    if not isfile(filePath) then
        Log("Sound file not found: " .. soundKey, "WARN")
        return
    end
    
    -- Create or retrieve cached sound instance
    local soundInstance = Instance.new("Sound")
    soundInstance.Name = "Pegamux_Sound_" .. soundKey
    soundInstance.SoundId = getcustomasset(filePath)
    soundInstance.Volume = volumeOverride or 0.5
    soundInstance.PlaybackSpeed = pitchOverride or 1.0
    soundInstance.RollOffMinDistance = 10
    soundInstance.RollOffMaxDistance = 100
    soundInstance.Parent = parentPart or Services.Workspace
    
    soundInstance:Play()
    
    -- Cleanup after playing
    soundInstance.Ended:Connect(function()
        if soundInstance and soundInstance.Parent then
            soundInstance:Destroy()
        end
    end)
    
    -- Safety cleanup using Debris service
    Services.Debris:AddItem(soundInstance, 5)
end

function SoundManager:PlayLooped(soundKey, parentPart, volumeOverride)
    local filePath = Config.Paths.Sounds .. soundKey .. ".mp3"
    if not isfile(filePath) then return end
    
    local soundInstance = Instance.new("Sound")
    soundInstance.SoundId = getcustomasset(filePath)
    soundInstance.Volume = volumeOverride or 0.3
    soundInstance.Looped = true
    soundInstance.Parent = parentPart or Services.Workspace
    soundInstance:Play()
    
    return soundInstance -- Return reference so caller can stop it later
end

-- ============================================================================
-- SECTION 6: ANIMATION CONTROLLER MODULE (NATIVE .ANIM SUPPORT)
-- Advanced module for loading and playing JSON-based Keyframe animations on R6 rigs.
-- Uses TweenService for smooth interpolation between poses.
-- ============================================================================

local AnimatorModule = {}
AnimatorModule.__index = AnimatorModule

-- Standard R6 Joint Default CFrames (Neutral Pose)
-- These represent the starting position of each joint relative to its parent.
local R6_DEFAULT_JOINTS = {
    ["Neck"] = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
    ["RootJoint"] = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
    ["Right Shoulder"] = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ["Left Shoulder"] = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Right Hip"] = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ["Left Hip"] = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Head"] = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
    ["Torso"] = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
    ["Right Arm"] = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ["Left Arm"] = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    ["Right Leg"] = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
    ["Left Leg"] = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
}

function AnimatorModule:new(rigModel)
    local self = setmetatable({}, AnimatorModule)
    self.Rig = rigModel
    self.Humanoid = rigModel:FindFirstChildOfClass("Humanoid")
    self.Joints = {}
    self.ActiveAnimations = {}
    self.IsInitialized = false
    
    -- Map standard joint names to actual instances in the Rig
    self:_InitializeJoints()
    
    return self
end

function AnimatorModule:_InitializeJoints()
    if not self.Rig or not self.Rig:FindFirstChild("Torso") then
        Log("Invalid Rig for Animator Initialization", "ERROR")
        return
    end
    
    local torso = self.Rig.Torso
    local rootPart = self.Rig:FindFirstChild("HumanoidRootPart")
    
    -- Define joint references based on R6 structure
    self.Joints["Head"] = torso:FindFirstChild("Neck")
    self.Joints["Torso"] = rootPart and (rootPart:FindFirstChild("RootJoint") or rootPart:FindFirstChild("Root Joint"))
    self.Joints["Left Arm"] = torso:FindFirstChild("Left Shoulder")
    self.Joints["Right Arm"] = torso:FindFirstChild("Right Shoulder")
    self.Joints["Left Leg"] = torso:FindFirstChild("Left Hip")
    self.Joints["Right Leg"] = torso:FindFirstChild("Right Hip")
    
    self.IsInitialized = true
    Log("Animator Joints Initialized.", "DEBUG")
end

-- Internal helper to apply a pose tween to a specific joint
function AnimatorModule:_ApplyPoseTween(jointName, targetCFrame, duration, easingStyle, easingDirection)
    local joint = self.Joints[jointName]
    if not joint then return end
    
    -- Calculate start and end CFrames
    local startCFrame = joint.C0
    local blendFactor = 0.35 -- How much influence the new pose has vs old
    
    -- Interpolate towards target
    local finalCFrame = startCFrame:Lerp(targetCFrame, blendFactor)
    
    local info = TweenInfo.new(
        duration or 0.2, 
        easingStyle or Enum.EasingStyle.Linear, 
        easingDirection or Enum.EasingDirection.Out
    )
    
    local tween = Services.TweenService:Create(joint, info, { C0 = finalCFrame })
    tween:Play()
    
    -- Clean up tween object after completion to save memory
    tween.Completed:Connect(function()
        if tween then tween:Destroy() end
    end)
end

-- Helper to convert array/string indices to EnumItems safely
local function GetEasingStyle(val)
    if typeof(val) == "EnumItem" then return val end
    if type(val) == "number" then
        local styles = {
            [0] = Enum.EasingStyle.Linear,
            [1] = Enum.EasingStyle.Sine,
            [2] = Enum.EasingStyle.Quadratic,
            [3] = Enum.EasingStyle.Cubic,
            [4] = Enum.EasingStyle.Quartic,
            [5] = Enum.EasingStyle.Quintic,
            [6] = Enum.EasingStyle.Bounce,
            [7] = Enum.EasingStyle.Elastic,
            [8] = Enum.EasingStyle.Back
        }
        return styles[val] or Enum.EasingStyle.Linear
    end
    if type(val) == "string" then
        local map = {
            ["Linear"] = Enum.EasingStyle.Linear,
            ["Sine"] = Enum.EasingStyle.Sine,
            ["Quadratic"] = Enum.EasingStyle.Quadratic,
            ["Cubic"] = Enum.EasingStyle.Cubic,
            ["Quartic"] = Enum.EasingStyle.Quartic,
            ["Quintic"] = Enum.EasingStyle.Quintic,
            ["Bounce"] = Enum.EasingStyle.Bounce,
            ["Elastic"] = Enum.EasingStyle.Elastic,
            ["Back"] = Enum.EasingStyle.Back
        }
        return map[val] or Enum.EasingStyle.Linear
    end
    return Enum.EasingStyle.Linear
end

local function GetEasingDirection(val)
    if typeof(val) == "EnumItem" then return val end
    if type(val) == "number" then
        local dirs = {
            [0] = Enum.EasingDirection.In,
            [1] = Enum.EasingDirection.Out,
            [2] = Enum.EasingDirection.InOut
        }
        return dirs[val] or Enum.EasingDirection.Out
    end
    if type(val) == "string" then
        local map = {
            ["In"] = Enum.EasingDirection.In,
            ["Out"] = Enum.EasingDirection.Out,
            ["InOut"] = Enum.EasingDirection.InOut
        }
        return map[val] or Enum.EasingDirection.Out
    end
    return Enum.EasingDirection.Out
end

function AnimatorModule:LoadAnimationFromData(animName, animData)
    if not self.IsInitialized then
        Log("Cannot load animation: Animator not initialized.", "ERROR")
        return nil
    end
    
    if not animData then return nil end
    
    local animObj = {
        Name = animName,
        Sequences = {},
        Length = 0,
        IsPlaying = false,
        Speed = 1,
        Loop = animData.Loop or false,
        CompletedEvent = Instance.new("BindableEvent"),
        KeyframeReachedEvent = Instance.new("BindableEvent")
    }
    
    -- Expecting animData.Keyframes to be an array of objects
    -- Each object: { Time = number, Poses = { { Name="Head", CFrame={...}, EasingStyle=..., ... } } }
    local keyframes = animData.Keyframes or {}
    
    table.sort(keyframes, function(a, b) return a.Time < b.Time end)
    
    for _, kf in ipairs(keyframes) do
        local frameData = {
            Time = kf.Time,
            Poses = {}
        }
        
        -- Process poses inside this keyframe
        local poses = kf.Poses or {}
        for _, pose in ipairs(poses) do
            -- Construct CFrame from data
            -- Assuming pose.CFrame is either a serialized table {x,y,z,r00,r01,...} or similar
            -- For simplicity in this example, we assume direct access or reconstruction logic needed
            -- Here we try to reconstruct if it's a flat array, otherwise skip
            
            local cf = nil
            if type(pose.CFrame) == "table" then
                -- Check if it looks like a serialized CFrame (usually 12 numbers + translation)
                -- Or just use Identity if parsing fails to prevent crash
                if #pose.CFrame >= 12 then
                     cf = CFrame.new(
                        pose.CFrame[1], pose.CFrame[2], pose.CFrame[3],
                        pose.CFrame[4], pose.CFrame[5], pose.CFrame[6],
                        pose.CFrame[7], pose.CFrame[8], pose.CFrame[9],
                        pose.CFrame[10], pose.CFrame[11], pose.CFrame[12]
                    )
                else
                    cf = CFrame.identity
                end
            elseif typeof(pose.CFrame) == "CFrame" then
                cf = pose.CFrame
            else
                cf = CFrame.identity
            end
            
            table.insert(frameData.Poses, {
                Name = pose.Name,
                CFrame = cf,
                EasingStyle = GetEasingStyle(pose.EasingStyle),
                EasingDirection = GetEasingDirection(pose.EasingDirection)
            })
        end
        
        table.insert(animObj.Sequences, frameData)
    end
    
    if #animObj.Sequences > 0 then
        animObj.Length = animObj.Sequences[#animObj.Sequences].Time
    end
    
    -- Store in active animations map
    self.ActiveAnimations[animName] = animObj
    
    Log("Animation Loaded from Data: " .. animName .. " (" .. animObj.Length .. "s)", "DEBUG")
    
    return animObj
end

function AnimatorModule:Play(animationName, speedMultiplier)
    local anim = self.ActiveAnimations[animationName]
    if not anim then
        Log("Animation not found: " .. animationName, "WARN")
        return
    end
    
    -- Stop other conflicting animations if necessary (simple priority system)
    -- For now, we allow overlapping but usually you want exclusive control per limb group
    -- This implementation assumes sequential playback or manual management by caller
    
    anim.Speed = speedMultiplier or 1
    anim.IsPlaying = true
    anim.Stopped = false
    
    task.spawn(function()
        local lastTime = 0
        
        repeat
            if anim.Stopped or not self.Humanoid or self.Humanoid.Health <= 0 then break end
            
            for i, frame in ipairs(anim.Sequences) do
                if anim.Stopped then break end
                
                local deltaTime = (frame.Time - lastTime) / anim.Speed
                if deltaTime < 0 then deltaTime = 0 end
                
                -- Apply all poses in this keyframe
                for _, pose in ipairs(frame.Poses) do
                    if self.Joints[pose.Name] then
                        -- Combine default joint CFrame with pose offset
                        local baseCF = R6_DEFAULT_JOINTS[pose.Name] or CFrame.identity
                        local targetCF = baseCF * pose.CFrame
                        
                        self:_ApplyPoseTween(pose.Name, targetCF, deltaTime, pose.EasingStyle, pose.EasingDirection)
                    end
                end
                
                -- Fire event for logic triggers (e.g., hitboxes)
                anim.KeyframeReachedEvent:Fire(frame.Name)
                
                -- Wait for the duration of this segment
                if deltaTime > 0 then
                    task.wait(deltaTime)
                end
                
                lastTime = frame.Time
            end
            
            -- Handle looping
            if anim.Loop then
                lastTime = 0
            else
                anim.IsPlaying = false
                anim.CompletedEvent:Fire()
                break
            end
            
        until not anim.Loop or anim.Stopped
        
        anim.IsPlaying = false
    end)
    
    return anim
end

function AnimatorModule:Stop(animationName)
    local anim = self.ActiveAnimations[animationName]
    if anim then
        anim.Stopped = true
        anim.IsPlaying = false
    end
end

function AnimatorModule:StopAll()
    for name, _ in pairs(self.ActiveAnimations) do
        self:Stop(name)
    end
end

-- ============================================================================
-- SECTION 7: CORE REANIMATE ENGINE
-- The heart of the system. Manages the invisible rig, accessory alignment, 
-- physics loops, and character lifecycle events.
-- ============================================================================

local ReanimateEngine = {}
ReanimateEngine.State = "INIT" -- INIT, RUNNING, STOPPED
ReanimateEngine.Rig = nil
ReanimateEngine.Character = nil
ReanimateEngine.AccessoryAlignments = {} -- List of { Handle, TargetPart, Offset }
ReanimateEngine.BlacklistedParts = {} -- Prevents double-binding same body part
ReanimateEngine.Animator = nil
ReanimateEngine.IsAlive = false
ReanimateEngine.Connections = {} -- Stores RBXScriptConnections for cleanup
ReanimateEngine.GameState = {
    IsAttacking = false,
    IsUsingAbility = false,
    IsRunning = false,
    LastAttackTime = 0
}

function ReanimateEngine:Initialize(parsedAnimations)
    Log("Initializing Reanimate Engine...", "INFO")
    
    -- 1. Create Invisible R6 Rig
    local description = Instance.new("HumanoidDescription")
    local rig = Services.Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R6)
    rig.Name = "Pegamux_Invisible_Rig"
    rig.Parent = Services.Workspace
    
    -- Configure Rig Properties
    for _, descendant in ipairs(rig:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Transparency = 1
            descendant.CanCollide = false
            descendant.Massless = true -- Helps with physics stability
        elseif descendant:IsA("Decal") then
            descendant.Transparency = 1
        end
    end
    
    self.Rig = rig
    self.Animator = AnimatorModule:new(rig)
    
    -- Load ALL parsed animations into the animator immediately
    if parsedAnimations then
        for name, data in pairs(parsedAnimations) do
            self.Animator:LoadAnimationFromData(name, data)
        end
        Log("Loaded " .. tostring(#parsedAnimations) .. " animations into Animator.", "INFO")
    end
    
    -- 2. Setup Character Event Listeners
    self:_SetupCharacterListeners()
    
    -- 3. Start Physics Loop
    self:_StartPhysicsLoop()
    
    -- 4. Setup Input Handlers
    self:_SetupInputHandlers()
    
    -- 5. AUTO-START TRIGGER (Break Joints to force reanimate entry)
    task.spawn(function()
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                Log("Auto-Reanimate Trigger Activated. Breaking Joints...", "WARN")
                hum:ChangeState(Enum.HumanoidStateType.Dead)
                -- Or simply destroy it so CharacterAdded fires cleanly
                LocalPlayer.Character:BreakJoints()
            end
        end
    end)
    
    self.State = "RUNNING"
    Log("Reanimate Engine Started Successfully.", "INFO")
end

function ReanimateEngine:_SetupCharacterListeners()
    -- Listen for initial character spawn
    if LocalPlayer.Character then
        self:OnCharacterAdded(LocalPlayer.Character)
    end
    
    -- Listen for respawns
    LocalPlayer.CharacterAdded:Connect(function(char)
        self:OnCharacterAdded(char)
    end)
    
    -- Listen for character removal/death
    LocalPlayer.CharacterRemoving:Connect(function(char)
        self:OnCharacterRemoved(char)
    end)
end

function ReanimateEngine:OnCharacterAdded(character)
    if character == self.Rig then return end
    
    Log("New Character Detected: Processing...", "INFO")
    
    self.Character = character
    self.IsAlive = true
    
    -- Clear previous alignments
    table.clear(self.AccessoryAlignments)
    table.clear(self.BlacklistedParts)
    
    -- Parent character to rig for visibility hierarchy
    character.Parent = self.Rig
    
    -- Disable default Roblox animation scripts to prevent conflict
    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        animateScript.Disabled = true
    end
    
    -- Process Accessories (Hat Reanimation Logic)
    task.spawn(function()
        self:_ProcessAccessories(character)
    end)
end

function ReanimateEngine:OnCharacterRemoved(character)
    Log("Character Removed. Cleaning up...", "DEBUG")
    self.IsAlive = false
    self.Character = nil
    
    -- Reset alignments
    table.clear(self.AccessoryAlignments)
end

-- ============================================================================
-- SECTION 8: HAT REANIMATION LOGIC (ACCESSORY MAPPING)
-- Implements the specific requirements: Head Replacement and Neck Color Coding.
-- ============================================================================

function ReanimateEngine:_ProcessAccessories(character)
    Log("Processing Accessories for Hat Reanimation...", "INFO")
    
    local headPart = character:FindFirstChild("Head")
    local torsoPart = character:FindFirstChild("Torso")
    
    if not headPart or not torsoPart then
        Log("Critical Body Parts Missing!", "ERROR")
        return
    end
    
    -- Iterate through all children of the character model
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") then
            local handle = child:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                self:_MapAccessoryToBodyPart(handle, child, character)
            end
        end
    end
    
    Log("Accessory Mapping Complete. Total Aligned: " .. #self.AccessoryAlignments, "INFO")
end

function ReanimateEngine:_MapAccessoryToBodyPart(accessoryHandle, accessoryObject, character)
    -- Extract Mesh ID from the accessory handle
    local meshIdStr = ""
    local textureIdStr = ""
    
    if accessoryHandle:IsA("MeshPart") then
        meshIdStr = accessoryHandle.MeshId
        textureIdStr = accessoryHandle.TextureID
    else
        -- Check for SpecialMesh inside non-MeshPart handles (older assets)
        local specialMesh = accessoryHandle:FindFirstChildOfClass("SpecialMesh")
        if specialMesh then
            meshIdStr = specialMesh.MeshId
            textureIdStr = specialMesh.TextureId
        end
    end
    
    -- Convert string ID to number for comparison
    local numericMeshId = tonumber(meshIdStr:match("%d+"))
    
    if not numericMeshId then return end
    
    -- ---------------------------------------------------------
    -- CASE 1: HEAD REPLACEMENT
    -- If the accessory matches the specific Head ID, bind it to Head.
    -- ---------------------------------------------------------
    if numericMeshId == Config.Assets.HeadReplacementID then
        Log("Detected Head Replacement Hat: " .. accessoryObject.Name, "INFO")
        
        -- Find the corresponding part in our Invisible Rig
        local rigHead = self.Rig:FindFirstChild("Head")
        if rigHead then
            table.insert(self.AccessoryAlignments, {
                Handle = accessoryHandle,
                TargetPart = rigHead,
                Offset = CFrame.identity, -- Perfect alignment
                Type = "HEAD"
            })
        end
        return -- Skip further processing for this item
    end
    
    -- ---------------------------------------------------------
    -- CASE 2: NECK ACCESSORIES (COLOR MAPPING)
    -- Check if the ID exists in our predefined NeckMap.
    -- ---------------------------------------------------------
    local targetPartName = Config.Assets.NeckAccessoriesMap[numericMeshId]
    
    if targetPartName then
        Log("Detected Neck Accessory mapped to: " .. targetPartName, "INFO")
        
        local rigTargetPart = nil
        
        -- Resolve string name to actual Rig Instance
        if targetPartName == "Torso" then
            rigTargetPart = self.Rig:FindFirstChild("Torso")
        elseif targetPartName == "LeftArm" then
            rigTargetPart = self.Rig:FindFirstChild("Left Arm")
        elseif targetPartName == "RightArm" then
            rigTargetPart = self.Rig:FindFirstChild("Right Arm")
        elseif targetPartName == "LeftLeg" then
            rigTargetPart = self.Rig:FindFirstChild("Left Leg")
        elseif targetPartName == "RightLeg" then
            rigTargetPart = self.Rig:FindFirstChild("Right Leg")
        end
        
        if rigTargetPart then
            -- Check blacklist to ensure we don't overload one body part with too many items
            -- unless intended. Here we allow one primary binding per slot for simplicity.
            if not self.BlacklistedParts[rigTargetPart] then
                self.BlacklistedParts[rigTargetPart] = true
                
                -- Determine appropriate offset based on part type
                -- Arms/Legs often need rotation corrections due to pivot points
                local adjustmentOffset = CFrame.identity
                if targetPartName == "LeftArm" or targetPartName == "RightArm" then
                    adjustmentOffset = CFrame.Angles(math.rad(90), 0, 0)
                elseif targetPartName == "LeftLeg" or targetPartName == "RightLeg" then
                    adjustmentOffset = CFrame.Angles(math.rad(90), 0, 0)
                end
                
                table.insert(self.AccessoryAlignments, {
                    Handle = accessoryHandle,
                    TargetPart = rigTargetPart,
                    Offset = adjustmentOffset,
                    Type = "NECK_MAPPED"
                })
            else
                Log("Slot occupied for " .. targetPartName .. ". Skipping duplicate.", "DEBUG")
            end
        end
        return
    end
    
    -- ---------------------------------------------------------
    -- CASE 3: GENERIC FALLBACK
    -- Any other accessory gets attached to the Head by default 
    -- to prevent it from falling off or floating randomly.
    -- ---------------------------------------------------------
    local rigHead = self.Rig:FindFirstChild("Head")
    if rigHead then
        table.insert(self.AccessoryAlignments, {
            Handle = accessoryHandle,
            TargetPart = rigHead,
            Offset = CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(90), 0, 0),
            Type = "GENERIC"
        })
    end
end

-- ============================================================================
-- SECTION 9: PHYSICS LOOP & ALIGNMENT ENGINE
-- Runs every frame to update positions of aligned accessories based on 
-- the movement of their target body parts in the invisible rig.
-- ============================================================================

function ReanimateEngine:_StartPhysicsLoop()
    Services.RunService.Stepped:Connect(function(_, dt)
        if self.State ~= "RUNNING" or not self.IsAlive then return end
        
        self:_UpdateAccessoryPositions(dt)
        self:_UpdateCameraSubject()
    end)
end

function ReanimateEngine:_UpdateAccessoryPositions(dt)
    local currentTime = tick()
    
    -- Calculate oscillation values for "anti-sleep" jitter
    -- This prevents Roblox physics engine from putting parts to sleep
    local frequency = Config.Physics.OscillationFrequency
    local amplitude = Config.Physics.OscillationAmplitude
    local antiSleepOffset = math.sin(currentTime * 15) * Config.Physics.AntiSleepStrength * Vector3.one
    
    local gravityComp = Config.Physics.GravityCompensationFactor + math.sin(currentTime)
    
    for _, align in ipairs(self.AccessoryAlignments) do
        local handle = align.Handle
        local target = align.TargetPart
        local offset = align.Offset
        
        -- Validate existence
        if not handle or not handle.Parent then continue end
        if not target or not target.Parent then continue end
        
        -- Only process if the handle is not anchored manually elsewhere
        if handle.Anchored then continue end
        
        -- 1. Velocity Transfer
        -- Copy linear velocity from target to handle, adding upward force to counter gravity
        local targetLinVel = target.AssemblyLinearVelocity
        local targetAngVel = target.AssemblyAngularVelocity
        
        -- Construct new velocity vector
        -- X/Z comes from target, Y is boosted to simulate being held up
        local newLinearVelocity = Vector3.new(
            targetLinVel.X, 
            gravityComp, -- Upward force
            targetLinVel.Z
        )
        
        handle.AssemblyLinearVelocity = newLinearVelocity
        handle.AssemblyAngularVelocity = targetAngVel
        
        -- 2. Position Locking (CFrame Alignment)
        -- Set handle's CFrame to match target's CFrame plus any static offset
        -- Add antiSleepOffset to keep physics engine awake
        handle.CFrame = target.CFrame * offset + antiSleepOffset
    end
end

function ReanimateEngine:_UpdateCameraSubject()
    -- Ensure camera always follows the invisible rig's humanoid
    -- This keeps the view stable even though the visible character is hidden/moved
    if self.Rig and self.Rig:FindFirstChildOfClass("Humanoid") then
        Camera.CameraSubject = self.Rig:FindFirstChildOfClass("Humanoid")
    end
end

-- ============================================================================
-- SECTION 10: FLING SYSTEM
-- High-impact physics manipulation to send targets flying.
-- ============================================================================

function ReanimateEngine:Fling(targetModel)
    if not targetModel or not targetModel:IsA("Model") then return end
    
    local hrp = targetModel:FindFirstChild("HumanoidRootPart")
    if not hrp or hrp.Anchored then return end
    
    -- Verify target is not ourselves
    if targetModel == self.Character then return end
    
    Log("Initiating Fling on: " .. targetModel.Name, "DEBUG")
    
    task.spawn(function()
        local velocityMagnitude = Config.Physics.FlingForceMultiplier
        local flingVector = Vector3.new(velocityMagnitude, velocityMagnitude, velocityMagnitude)
        
        local startTime = tick()
        local duration = 0.15 -- Short burst for maximum impact without lag
        
        while tick() - startTime < duration do
            if not hrp or not hrp.Parent then break end
            
            -- Apply extreme velocity
            hrp.AssemblyLinearVelocity = flingVector
            hrp.AssemblyAngularVelocity = flingVector
            
            -- Tiny randomization to prevent physics stacking/collision locks
            local jitter = Vector3.new(
                math.random(-1, 1) / 100,
                math.random(-1, 1) / 100,
                math.random(-1, 1) / 100
            )
            hrp.CFrame = hrp.CFrame * CFrame.new(jitter)
            
            task.wait()
        end
        
        -- Optional: Play hit sound at impact location
        SoundManager:Play("Hit", hrp, 0.8, 1.2)
    end)
end

-- ============================================================================
-- SECTION 11: INPUT HANDLING & COMBAT LOGIC
-- Maps keyboard/mouse inputs to gameplay actions.
-- ============================================================================

function ReanimateEngine:_SetupInputHandlers()
    Services.UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end -- Ignore if UI consumed input
        
        self:_HandleInput(input)
    end)
    
    Services.UserInputService.InputEnded:Connect(function(input)
        self:_HandleInputEnd(input)
    end)
end

function ReanimateEngine:_HandleInput(input)
    -- Mouse Click (Attack/Fling)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        self:_ExecutePrimaryAction()
    end
    
    -- Keyboard Abilities
    if input.KeyCode == Enum.KeyCode.Q then
        self:_ExecuteAbility("DigitalFootprint")
    elseif input.KeyCode == Enum.KeyCode.E then
        self:_ExecuteAbility("CorruptEnergy")
    elseif input.KeyCode == Enum.KeyCode.Z then
        self:_ExecuteKillAnimation("Default")
    elseif input.KeyCode == Enum.KeyCode.C then
        self:_ExecuteKillAnimation("Milestone4")
    elseif input.KeyCode == Enum.KeyCode.X then
        self:_ExecuteKillAnimation("Legacy")
    elseif input.KeyCode == Enum.KeyCode.V then
        self:_ExecuteKillAnimation("Screamer")
    end
    
    -- Sprint Toggle
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        self.GameState.IsRunning = true
        self:_UpdateWalkSpeed()
    end
end

function ReanimateEngine:_HandleInputEnd(input)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        self.GameState.IsRunning = false
        self:_UpdateWalkSpeed()
    end
end

function ReanimateEngine:_ExecutePrimaryAction()
    if self.GameState.IsAttacking or self.GameState.IsUsingAbility then return end
    
    local target = Mouse.Target
    if not target then return end
    
    local model = target:FindFirstAncestorOfClass("Model")
    local humanoid = model and model:FindFirstChildOfClass("Humanoid")
    
    if humanoid and humanoid.Health > 0 and model ~= self.Character then
        -- Perform Fling
        self:Fling(model)
        
        -- Trigger Visual Attack Animation
        self:_PlayAnimation("Slash", 1.2)
        SoundManager:Play("Slash", self.Character, 0.7, 1.1)
        
        -- Cooldown
        self.GameState.IsAttacking = true
        task.delay(Config.Gameplay.AttackCooldown, function()
            self.GameState.IsAttacking = false
        end)
    end
end

function ReanimateEngine:_ExecuteAbility(abilityName)
    if self.GameState.IsUsingAbility then return end
    
    self.GameState.IsUsingAbility = true
    Log("Executing Ability: " .. abilityName, "INFO")
    
    if abilityName == "DigitalFootprint" then
        self:_PlayAnimation("Digital_Footprint", 1)
        SoundManager:Play("Stomp", self.Character, 0.9, 1)
        
        -- Area of Effect Logic would go here
        -- For now, just visual/audio feedback
        
    elseif abilityName == "CorruptEnergy" then
        self:_PlayAnimation("Corrupt_Energy", 1)
        SoundManager:Play("Energy", self.Character, 0.8, 1)
        
        -- Spike generation logic could be added here
    end
    
    task.delay(Config.Gameplay.AbilityCooldown, function()
        self.GameState.IsUsingAbility = false
    end)
end

function ReanimateEngine:_ExecuteKillAnimation(typeName)
    if self.GameState.IsUsingAbility then return end
    
    self.GameState.IsUsingAbility = true
    Log("Triggering Kill Animation: " .. typeName, "INFO")
    
    -- In a full implementation, this would spawn an NPC dummy, 
    -- play synchronized killer/victim animations, and remove the victim.
    -- Simplified version for this scope:
    
    local animName = "KillerExecution_" .. typeName
    if self.Animator.ActiveAnimations[animName] then
        self:_PlayAnimation(animName, 1)
        SoundManager:Play("Kill", self.Character, 1.0, 1)
    else
        Log("Kill Animation Not Found: " .. animName, "WARN")
    end
    
    task.delay(Config.Gameplay.KillAnimationDuration, function()
        self.GameState.IsUsingAbility = false
    end)
end

function ReanimateEngine:_UpdateWalkSpeed()
    if not self.Rig or not self.Rig:FindFirstChildOfClass("Humanoid") then return end
    
    local humanoid = self.Rig:FindFirstChildOfClass("Humanoid")
    
    if self.GameState.IsRunning then
        humanoid.WalkSpeed = Config.Gameplay.WalkSpeedRun
    else
        humanoid.WalkSpeed = Config.Gameplay.WalkSpeedNormal
    end
end

-- ============================================================================
-- SECTION 12: MOVEMENT STATE MACHINE (HEARTBEAT CHECKER)
-- Detects idle/walking/running states to switch animations automatically.
-- ============================================================================

Services.RunService.Heartbeat:Connect(function()
    if ReanimateEngine.State ~= "RUNNING" or not ReanimateEngine.IsAlive then return end
    
    local char = ReanimateEngine.Character
    local rig = ReanimateEngine.Rig
    
    if not char or not rig then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local velocity = rootPart.Velocity.Magnitude
    local isGrounded = Services.Workspace:FindPartOnRay(
        Ray.new(rootPart.Position, rootPart.Position + Vector3.new(0, -1, 0)), 
        char
    ) ~= nil
    
    -- Determine State
    local currentState = "Idle"
    if velocity > 1 and isGrounded then
        if ReanimateEngine.GameState.IsRunning then
            currentState = "Sprint"
        else
            currentState = "Walk"
        end
    elseif not isGrounded then
        currentState = "Jump" -- Could add jump animation support here
    end
    
    -- Switch Animation if State Changed
    -- Simple debounce to prevent spamming plays
    if ReanimateEngine._LastMovementState ~= currentState then
        ReanimateEngine._LastMovementState = currentState
        
        if currentState == "Idle" then
            ReanimateEngine:_PlayAnimation("Idle", 1)
        elseif currentState == "Walk" then
            ReanimateEngine:_PlayAnimation("Walk", 1)
        elseif currentState == "Sprint" then
            ReanimateEngine:_PlayAnimation("Sprint", 1)
        end
    end
end)

function ReanimateEngine:_PlayAnimation(name, speed)
    if self.Animator then
        self.Animator:Play(name, speed)
    end
end

-- ============================================================================
-- SECTION 13: MOBILE UI MANAGER (NEW ADDITION)
-- Adds 3 touch-friendly buttons for mobile users.
-- ============================================================================

local MobileUI = {}

function MobileUI:Initialize()
    Log("Initializing Mobile UI...", "DEBUG")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Pegamux_MobileUI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 500 -- Below loading screen, above game
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Button Template Creator
    local function CreateActionButton(name, pos, size, color, actionFunc)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = true
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        btn.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = btn
        
        -- Visual Press Effect
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = color:Lerp(Color3.new(1,1,1), 0.2)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = color
        end)
        
        -- Action Binding
        btn.Activated:Connect(actionFunc)
        
        return btn
    end
    
    -- 1. ATTACK BUTTON (Bottom Right)
    CreateActionButton("ATTACK", UDim2.new(1, -120, 1, -120), UDim2.new(0, 100, 0, 100), Color3.fromRGB(200, 50, 50), function()
        ReanimateEngine:_ExecutePrimaryAction()
    end)
    
    -- 2. ABILITY BUTTON (Above Attack)
    CreateActionButton("ABILITY", UDim2.new(1, -120, 1, -230), UDim2.new(0, 80, 0, 80), Color3.fromRGB(50, 150, 200), function()
        ReanimateEngine:_ExecuteAbility("CorruptEnergy") -- Default ability for mobile tap
    end)
    
    -- 3. RUN TOGGLE BUTTON (Left Side)
    local runBtn = CreateActionButton("RUN", UDim2.new(0, 20, 1, -120), UDim2.new(0, 80, 0, 80), Color3.fromRGB(50, 200, 100), function()
        ReanimateEngine.GameState.IsRunning = not ReanimateEngine.GameState.IsRunning
        ReanimateEngine:_UpdateWalkSpeed()
        
        -- Update button text/color based on state
        if ReanimateEngine.GameState.IsRunning then
            runBtn.Text = "STOP"
            runBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        else
            runBtn.Text = "RUN"
            runBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
        end
    end)
    
    MobileUI.ScreenGui = screenGui
end

function MobileUI:Hide()
    if MobileUI.ScreenGui then
        MobileUI.ScreenGui:Destroy()
    end
end

-- ============================================================================
-- SECTION 14: MAIN EXECUTION ENTRY POINT
-- Starts the entire system.
-- ============================================================================

local function Main()
    Log("=== BOOT SEQUENCE START ===", "INFO")
    
    -- 1. Init Loading Screen FIRST
    LoadingScreen:Initialize()
    
    -- 2. Prepare Assets (This blocks until downloads finish)
    local ParsedAnims = AssetManager:PrepareAllAssets()
    
    -- 3. Hide Loading Screen once ready
    LoadingScreen:Hide()
    
    -- 4. Init Engine (Pass parsed animations directly)
    ReanimateEngine:Initialize(ParsedAnims)
    
    -- 5. Init Mobile UI AFTER engine starts
    task.wait(1) -- Give time for reanimate to settle
    MobileUI:Initialize()
    
    Log("=== BOOT SEQUENCE COMPLETE ===", "INFO")
    Log("Controls:", "INFO")
    Log("- PC: Click=Fling, Q/E=Abilities, Shift=Run", "INFO")
    Log("- Mobile: Use On-Screen Buttons", "INFO")
end

-- Run Main Function
Main()

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
