-- modules/headexpander.lua
-- Head Expander ist DEAKTIVIERT (nur Infinite Jump und Walk Speed funktionieren)
local HeadExpander = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ========== HEAD EXPANDER (DEAKTIVIERT) ==========
-- Die Funktionen existieren, machen aber NICHTS
local enabled = false

function HeadExpander.toggle(state)
    enabled = state
    if state then
        print("Head Expander ist DEAKTIVIERT in dieser Version")
        -- Keine Aktion
    end
end

function HeadExpander.isEnabled()
    return false -- Immer false, egal was die UI sagt
end

function HeadExpander.updateSize()
    -- Macht nichts
end

function HeadExpander.resetHeadExpander()
    -- Macht nichts
end

-- ========== INFINITE JUMP (funktioniert) ==========
local infiniteEnabled = false
local infiniteConn = nil

function HeadExpander.toggleInfiniteJump(state)
    infiniteEnabled = state
    
    if state then
        if not infiniteConn then
            infiniteConn = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        hum:ChangeState("Jumping")
                    end
                end
            end)
        end
    else
        if infiniteConn then
            infiniteConn:Disconnect()
            infiniteConn = nil
        end
    end
end

function HeadExpander.isInfiniteJumpEnabled()
    return infiniteEnabled
end

function HeadExpander.resetInfiniteJump()
    HeadExpander.toggleInfiniteJump(false)
end

-- ========== WALK SPEED (funktioniert) ==========
local walkEnabled = false
local walkConn = nil
local normalSpeed = 16
local sprintSpeed = 35
local currentSpeed = 16

local function updateWalk()
    if not walkEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    local sprint = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    local newSpeed = sprint and sprintSpeed or normalSpeed
    
    if currentSpeed ~= newSpeed then
        currentSpeed = newSpeed
        hum.WalkSpeed = currentSpeed
    end
end

function HeadExpander.toggleWalkSpeed(state)
    walkEnabled = state
    
    if state then
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = currentSpeed end
        end
        if not walkConn then
            walkConn = RunService.Heartbeat:Connect(updateWalk)
        end
    else
        if walkConn then
            walkConn:Disconnect()
            walkConn = nil
        end
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
end

function HeadExpander.isWalkSpeedEnabled()
    return walkEnabled
end

function HeadExpander.setNormalWalkSpeed(speed)
    normalSpeed = speed
    if walkEnabled then
        currentSpeed = speed
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = speed end
        end
    end
end

function HeadExpander.setSprintWalkSpeed(speed)
    sprintSpeed = speed
end

function HeadExpander.resetWalkSpeed()
    HeadExpander.toggleWalkSpeed(false)
    if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags then
        _G.UltimateCheat.Rayfield.Flags.NormalWalkSpeed:Set(16)
        _G.UltimateCheat.Rayfield.Flags.SprintWalkSpeed:Set(35)
    end
    normalSpeed = 16
    sprintSpeed = 35
    currentSpeed = 16
end

function HeadExpander.init()
    print("Head Expander ist DEAKTIVIERT - Nur Infinite Jump und Walk Speed funktionieren")
end

return HeadExpander
