-- modules/headexpander.lua
-- Einfacher Head Expander - KEINE komplexen Funktionen
local HeadExpander = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Zustand
local enabled = false
local connection = nil
local lastUpdate = 0

-- Größentabelle (einfach)
local originalSizes = {}
local originalCollisions = {}

-- Head wiederherstellen
local function restoreHead(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    local old = originalSizes[char]
    if old then
        pcall(function()
            head.Size = old
            head.CanCollide = originalCollisions[char] or false
        end)
        originalSizes[char] = nil
        originalCollisions[char] = nil
    end
end

-- Alle Heads zurücksetzen
local function restoreAll()
    for char, _ in pairs(originalSizes) do
        restoreHead(char)
    end
    originalSizes = {}
    originalCollisions = {}
end

-- Head vergrößern
local function expandHead(char, size)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    -- Speichern wenn noch nicht gespeichert
    if originalSizes[char] == nil then
        originalSizes[char] = head.Size
        originalCollisions[char] = head.CanCollide
    end
    
    pcall(function()
        head.Size = Vector3.new(size, size, size)
        head.CanCollide = true
    end)
end

-- Update-Funktion (wird selten aufgerufen)
local function update()
    if not enabled then return end
    
    -- Nur alle 1.5 Sekunden updaten (sehr langsam)
    local now = tick()
    if now - lastUpdate < 1.5 then return end
    lastUpdate = now
    
    local size = 5
    if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.HeadSize then
        size = _G.UltimateCheat.Rayfield.Flags.HeadSize.CurrentValue
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            expandHead(player.Character, size)
        end
    end
end

-- NEUER SPIELER: Charakter erscheint später
local function onPlayerAdded(player)
    if player == LocalPlayer then return end
    
    -- Warten bis Charakter da ist
    local conn
    conn = player.CharacterAdded:Connect(function(char)
        task.wait(1.5) -- Warten bis Charakter komplett geladen
        if enabled and char then
            local size = 5
            if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.HeadSize then
                size = _G.UltimateCheat.Rayfield.Flags.HeadSize.CurrentValue
            end
            expandHead(char, size)
        end
        if conn then conn:Disconnect() end
    end)
end

-- ========== ÖFFENTLICHE FUNKTIONEN ==========
function HeadExpander.toggle(state)
    enabled = state
    
    if state then
        -- Einmalig alle Köpfe setzen
        update()
        
        -- Heartbeat mit sehr langsamem Update
        if not connection then
            connection = RunService.Heartbeat:Connect(update)
        end
        
        -- Für neue Spieler
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                onPlayerAdded(player)
            end
        end
        Players.PlayerAdded:Connect(onPlayerAdded)
        
    else
        -- Ausschalten
        if connection then
            connection:Disconnect()
            connection = nil
        end
        restoreAll()
    end
end

function HeadExpander.isEnabled()
    return enabled
end

function HeadExpander.updateSize()
    if enabled then
        update()
    end
end

function HeadExpander.resetHeadExpander()
    HeadExpander.toggle(false)
    if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags then
        _G.UltimateCheat.Rayfield.Flags.HeadSize:Set(5)
    end
end

-- ========== INFINITE JUMP (einfach) ==========
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

-- ========== WALK SPEED (einfach) ==========
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
    -- nichts
end

return HeadExpander
