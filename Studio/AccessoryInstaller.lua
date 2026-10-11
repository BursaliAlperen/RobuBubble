-- RobuBubble Studio accessory importer
-- Run this ONCE in Roblox Studio's Command Bar for your own experience.
-- This uses Roblox Studio's InsertService, not loadstring/executor APIs.
-- Imported assets are stored in ServerStorage/RobuBubbleAccessories.
local InsertService = game:GetService("InsertService")
local ServerStorage = game:GetService("ServerStorage")

local IDS = {
    Head = 134624581597947,
    Neck = {
        88886554182275,
        90788603154080,
        120111604252410,
        128893482026011,
        87291559615126,
    },
}

local folder = ServerStorage:FindFirstChild("RobuBubbleAccessories")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "RobuBubbleAccessories"
    folder.Parent = ServerStorage
end

local function findAccessory(root)
    if root:IsA("Accessory") then
        return root
    end
    for _, item in ipairs(root:GetDescendants()) do
        if item:IsA("Accessory") then
            return item
        end
    end
    return nil
end

local function importAsset(id, name)
    local ok, assetOrError = pcall(function()
        return InsertService:LoadAsset(id)
    end)
    if not ok then
        warn(("[RobuBubble] Asset %d could not be loaded: %s"):format(id, tostring(assetOrError)))
        return false
    end

    local asset = assetOrError
    local accessory = findAccessory(asset)
    if not accessory then
        warn(("[RobuBubble] Asset %d did not contain an Accessory. Left untouched; inspect it manually."):format(id))
        asset:Destroy()
        return false
    end

    local clone = accessory:Clone()
    clone.Name = name
    clone:SetAttribute("SourceAssetId", id)
    clone.Parent = folder
    asset:Destroy()
    print(("[RobuBubble] Imported %s (asset %d)"):format(name, id))
    return true
end

importAsset(IDS.Head, "HeadAccessory_134624581597947")
for _, id in ipairs(IDS.Neck) do
    importAsset(id, "NeckAccessory_" .. tostring(id))
end

print("[RobuBubble] Import pass finished. Review warnings and inspect every imported accessory in ServerStorage.")
