-- modules/headexpander.lua
local HeadExpander = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Originalen LimbExtender laden (nur einmal)
local LimbExtender = nil
local limbInstance = nil

local function getLimbExtender()
    if not LimbExtender then
        LimbExtender = loadstring(game:HttpGet('https://raw.githubusercontent.com/AAPVdev/scripts/refs/heads/main/LimbExtender.lua'))()
    end
    return LimbExtender
end

local headExpanderEnabled = false
local originalHeadSizes = {}

-- HEAD EXPANDER mit originalem LimbExtender
function HeadExpander.toggle(state)
    headExpanderEnabled = state
    
    if state then
        -- LimbExtender initialisieren (nur für Head)
        if not limbInstance then
            local LE = getLimbExtender()
            limbInstance = LE({
                LISTEN_FOR_INPUT = false,
                USE_HIGHLIGHT = false,
            })
        end
        
        -- Nur Head targeten
        limbInstance:Set("TARGET_LIMB", "Head")
        
        -- Head Size aus UI übernehmen
        local headSize = 5
        if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.HeadSize then
            headSize = _G.UltimateCheat.Rayfield.Flags.HeadSize.CurrentValue
        end
        limbInstance:Set("LIMB_SIZE", headSize)
        
        -- Aktivieren
        limbInstance:Toggle(true)
        
    else
        -- Deaktivieren
        if limbInstance then
            limbInstance:Toggle(false)
        end
    end
end

function HeadExpander.isEnabled()
    return headExpanderEnabled
end

function HeadExpander.updateSize()
    if headExpanderEnabled and limbInstance then
        local headSize = 5
        if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.HeadSize then
            headSize = _G.UltimateCheat.Rayfield.Flags.HeadSize.CurrentValue
        end
        limbInstance:Set("LIMB_SIZE", headSize)
    end
end

function HeadExpander.resetHeadExpander()
    HeadExpander.toggle(false)
    if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags then
        _G.UltimateCheat.Rayfield.Flags.HeadSize:Set(5)
    end
end

-- INFINITE JUMP (unverändert)
local infiniteJumpEnabled = false
local infiniteJumpConnection = nil

function HeadExpander.toggleInfiniteJump(state)
    infiniteJumpEnabled = state
    
    if state then
        if not infiniteJumpConnection then
            infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character then
                    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState("Jumping")
                    end
                end
            end)
        end
    else
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
        end
    end
end

function HeadExpander.isInfiniteJumpEnabled()
    return infiniteJumpEnabled
end

function HeadExpander.resetInfiniteJump()
    HeadExpander.toggleInfiniteJump(false)
end

-- WALK SPEED (unverändert)
local walkSpeedEnabled = false
local walkSpeedConnection = nil
local normalWalkSpeed = 16
local sprintWalkSpeed = 35
local currentWalkSpeed = 16
local isSprinting = false

local function updateWalkSpeed()
    if not walkSpeedEnabled or not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
        isSprinting = true
        currentWalkSpeed = sprintWalkSpeed
    else
        isSprinting = false
        currentWalkSpeed = normalWalkSpeed
    end
    
    humanoid.WalkSpeed = currentWalkSpeed
end

function HeadExpander.toggleWalkSpeed(state)
    walkSpeedEnabled = state
    
    if state then
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = currentWalkSpeed
            end
        end
        
        if not walkSpeedConnection then
            walkSpeedConnection = RunService.Heartbeat:Connect(updateWalkSpeed)
        end
        
        LocalPlayer.CharacterAdded:Connect(function(character)
            task.wait(0.1)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and walkSpeedEnabled then
                humanoid.WalkSpeed = currentWalkSpeed
            end
        end)
    else
        if walkSpeedConnection then
            walkSpeedConnection:Disconnect()
            walkSpeedConnection = nil
        end
        
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end
end

function HeadExpander.isWalkSpeedEnabled()
    return walkSpeedEnabled
end

function HeadExpander.setNormalWalkSpeed(speed)
    normalWalkSpeed = speed
    if not isSprinting and walkSpeedEnabled then
        currentWalkSpeed = speed
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = speed end
        end
    end
end

function HeadExpander.setSprintWalkSpeed(speed)
    sprintWalkSpeed = speed
    if isSprinting and walkSpeedEnabled then
        currentWalkSpeed = speed
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = speed end
        end
    end
end

function HeadExpander.resetWalkSpeed()
    HeadExpander.toggleWalkSpeed(false)
    if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags then
        _G.UltimateCheat.Rayfield.Flags.NormalWalkSpeed:Set(16)
        _G.UltimateCheat.Rayfield.Flags.SprintWalkSpeed:Set(35)
    end
    normalWalkSpeed = 16
    sprintWalkSpeed = 35
    currentWalkSpeed = 16
    isSprinting = false
end

function HeadExpander.init()
    -- Nichts tun
end

return HeadExpander
