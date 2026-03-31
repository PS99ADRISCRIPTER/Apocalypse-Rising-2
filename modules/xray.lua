-- modules/xray.lua
local XRay = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local XRAY_ACTIVE = false
local TARGET_TRANSPARENCY = 0.8
local IGNORE_THRESHOLD = 0.8
local affectedParts = {}

local function shouldIgnorePart(part)
    return part.Transparency >= IGNORE_THRESHOLD
end

function XRay.toggle()
    if not XRAY_ACTIVE then
        affectedParts = {}
        local changedCount = 0
        local ignoredCount = 0
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if not shouldIgnorePart(obj) then
                    local isPlayerPart = false
                    for _, player in pairs(Players:GetPlayers()) do
                        if player.Character and obj:IsDescendantOf(player.Character) then
                            isPlayerPart = true
                            break
                        end
                    end
                    
                    if not isPlayerPart then
                        affectedParts[obj] = obj.Transparency
                        obj.Transparency = TARGET_TRANSPARENCY
                        changedCount = changedCount + 1
                    end
                else
                    ignoredCount = ignoredCount + 1
                end
            end
        end
        
        XRAY_ACTIVE = true
        print(string.format("X-Ray ENABLED: %d parts changed, %d parts ignored", changedCount, ignoredCount))
    else
        local restoredCount = 0
        for part, transparency in pairs(affectedParts) do
            if part and part.Parent then
                part.Transparency = transparency
                restoredCount = restoredCount + 1
            end
        end
        
        affectedParts = {}
        XRAY_ACTIVE = false
        print(string.format("X-Ray DISABLED: %d parts restored", restoredCount))
    end
end

function XRay.isActive()
    return XRAY_ACTIVE
end

function XRay.setTransparency(trans)
    TARGET_TRANSPARENCY = trans
    if XRAY_ACTIVE then
        for part, _ in pairs(affectedParts) do
            if part and part.Parent then
                part.Transparency = trans
            end
        end
    end
end

function XRay.init()
    Players.PlayerRemoving:Connect(function(player)
        if player == LocalPlayer and XRAY_ACTIVE then
            XRay.toggle()
        end
    end)
end

return XRay
