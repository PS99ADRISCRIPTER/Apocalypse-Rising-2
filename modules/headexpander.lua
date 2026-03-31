-- modules/headexpander.lua
local HeadExpander = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ========== KOPIE DER ORIGINAL-LOGIK AUS LIMBEXTENDER ==========
-- (nur für Head, ohne ConnectionManager/Streamable)

local headExpanderEnabled = false
local originalHeadSizes = {}
local originalHeadCollisions = {}
local updateConnection = nil
local lastUpdate = 0
local UPDATE_INTERVAL = 0.25

-- Helper: Eigenschaftsänderungen überwachen (wie im Original)
local function watchProperty(instance, prop, callback)
    if not instance or type(prop) ~= "string" or type(callback) ~= "function" then 
        return nil 
    end
    local signal = instance:GetPropertyChangedSignal(prop)
    if signal and type(signal.Connect) == "function" then
        return signal:Connect(function() callback(instance) end)
    end
    return nil
end

-- Head speichern (wie original saveLimbProperties)
local function saveHeadProperties(head)
    if not head then return end
    if originalHeadSizes[head] then return end
    
    originalHeadSizes[head] = {
        OriginalSize = head.Size,
        OriginalCanCollide = head.CanCollide,
        SizeConnection = nil,
        CollisionConnection = nil,
    }
end

-- Head wiederherstellen (wie original restoreLimbProperties)
local function restoreHeadProperties(head)
    if not head then return end
    local saved = originalHeadSizes[head]
    if not saved then return end
    
    if saved.SizeConnection and typeof(saved.SizeConnection) == "RBXScriptConnection" then
        saved.SizeConnection:Disconnect()
    end
    if saved.CollisionConnection and typeof(saved.CollisionConnection) == "RBXScriptConnection" then
        saved.CollisionConnection:Disconnect()
    end
    
    if head and head.Parent then
        head.Size = saved.OriginalSize
        head.CanCollide = saved.OriginalCanCollide
    end
    
    originalHeadSizes[head] = nil
end

-- Head modifizieren (wie original modifyLimbProperties)
local function modifyHeadProperties(head, headSize, canCollide)
    if not head then return end
    if originalHeadSizes[head] then return end
    
    saveHeadProperties(head)
    local saved = originalHeadSizes[head]
    
    -- Überwache Änderungen (wie im Original)
    saved.SizeConnection = watchProperty(head, "Size", function(h)
        pcall(function() h.Size = Vector3.new(headSize, headSize, headSize) end)
    end)
    
    saved.CollisionConnection = watchProperty(head, "CanCollide", function(h)
        pcall(function() h.CanCollide = canCollide end)
    end)
    
    -- Direkt setzen
    pcall(function()
        head.Size = Vector3.new(headSize, headSize, headSize)
        head.CanCollide = canCollide
        head.Massless = true
    end)
end

-- Alle Heads aktualisieren
local function updateAllHeads()
    if not headExpanderEnabled then return end
    
    local now = tick()
    if now - lastUpdate < UPDATE_INTERVAL then return end
    lastUpdate = now
    
    local headSize = 5
    if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.HeadSize then
        headSize = _G.UltimateCheat.Rayfield.Flags.HeadSize.CurrentValue
    end
    local canCollide = true
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                modifyHeadProperties(head, headSize, canCollide)
            end
        end
    end
end

-- Alle Heads zurücksetzen
local function restoreAllHeads()
    for head, _ in pairs(originalHeadSizes) do
        restoreHeadProperties(head)
    end
    originalHeadSizes = {}
end

-- Charakter-Hinzufügung
local function onCharacterAdded(character)
    task.wait(0.3)
    if headExpanderEnabled then
        local headSize = 5
        if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.HeadSize then
            headSize = _G.UltimateCheat.Rayfield.Flags.HeadSize.CurrentValue
        end
        local head = character:FindFirstChild("Head")
        if head then
            modifyHeadProperties(head, headSize, true)
        end
    end
end

-- ========== PUBLIC FUNCTIONS ==========
function HeadExpander.toggle(state)
    headExpanderEnabled = state
    
    if state then
        updateAllHeads()
        
        if not updateConnection then
            updateConnection = RunService.Heartbeat:Connect(updateAllHeads)
        end
        
        -- Bestehende Spieler
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                player.CharacterAdded:Connect(onCharacterAdded)
            end
        end
        
        -- Neue Spieler
        Players.PlayerAdded:Connect(function(player)
            if player ~= LocalPlayer then
                player.CharacterAdded:Connect(onCharacterAdded)
            end
        end)
        
    else
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
        restoreAllHeads()
    end
end

function HeadExpander.isEnabled()
    return headExpanderEnabled
end

function HeadExpander.updateSize()
    if headExpanderEnabled then
        updateAllHeads()
    end
end

function HeadExpander.resetHeadExpander()
    HeadExpander.toggle(false)
    if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags then
        _G.UltimateCheat.Rayfield.Flags.HeadSize:Set(5)
    end
end

-- ========== INFINITE JUMP ==========
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

-- ========== WALK SPEED ==========
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
