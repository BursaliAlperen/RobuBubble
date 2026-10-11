-- Read-only Studio animation/model audit.
-- Run from the Studio Command Bar after importing the repository's models into Workspace or ReplicatedStorage.
-- This script does not delete, reparent, or modify any instances.

local roots = {
    game:GetService("ReplicatedStorage"),
    workspace,
}

local seen = {}
local function safeName(instance)
    local ok, result = pcall(function()
        return instance:GetFullName()
    end)
    return ok and result or instance.Name
end

local function auditRoot(root)
    if not root then return end
    for _, instance in ipairs(root:GetDescendants()) do
        if not seen[instance] then
            seen[instance] = true
            if instance:IsA("KeyframeSequence") then
                local keyframes = instance:GetKeyframes()
                local poseCount = 0
                local maxTime = 0
                for _, keyframe in ipairs(keyframes) do
                    maxTime = math.max(maxTime, keyframe.Time)
                    for _, descendant in ipairs(keyframe:GetDescendants()) do
                        if descendant:IsA("Pose") then
                            poseCount += 1
                        end
                    end
                end
                print(("[AnimsAudit] Sequence=%s | Keyframes=%d | Poses=%d | Duration=%.3fs | Loop=%s | Priority=%s")
                    :format(safeName(instance), #keyframes, poseCount, maxTime, tostring(instance.Loop), tostring(instance.Priority)))
            elseif instance:IsA("Motor6D") then
                print(("[AnimsAudit] Motor6D=%s | Part0=%s | Part1=%s")
                    :format(safeName(instance), instance.Part0 and instance.Part0.Name or "nil", instance.Part1 and instance.Part1.Name or "nil"))
            elseif instance:IsA("Animation") then
                print(("[AnimsAudit] Animation=%s | AnimationId=%s")
                    :format(safeName(instance), instance.AnimationId))
            end
        end
    end
end

local ok, err = pcall(function()
    for _, root in ipairs(roots) do
        auditRoot(root)
    end
end)

if ok then
    print("[AnimsAudit] Complete. No instances were modified.")
else
    warn("[AnimsAudit] Failed safely: " .. tostring(err))
end
