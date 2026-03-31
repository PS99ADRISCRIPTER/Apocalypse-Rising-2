-- modules/headexpander.lua
local HeadExpander = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Globale Variablen
local headExpanderEnabled = false
local originalHeadSizes = {}
local originalHeadCollisions = {}
local updateConnection = nil
local lastUpdate = 0
local UPDATE_INTERVAL = 0.3 -- Nur alle 0.3 Sekunden updaten

-- HEAD EXPANDER FUNKTION (nur Head, keine anderen Limbs)
local function expandHead(character, size)
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    -- Nur wenn sich die Größe ändert
    if head.Size == Vector3.new(size, size, size) then
        return
    end
    
    -- Originalwerte speichern
    if not originalHeadSizes[character] then
        originalHeadSizes[character] = head.Size
        originalHeadCollisions[character] = head.CanCollide
    end
    
    -- Größe ändern
    pcall(function()
        head.Size = Vector3.new(size, size, size)
        head.CanCollide = true
    end)
end

local function restoreHead(character)
    if not character then return end
    
    if originalHeadSizes[character] then
        local head = character:FindFirstChild("Head")
        if head then
            pcall(function()
                head.Size = originalHeadSizes[character]
                head.CanCollide = originalHeadCollisions[character] or false
            end)
        end
        originalHeadSizes[character] = nil
        originalHeadCollisions[character] = nil
    end
end

local function restoreAllHeads()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            restoreHead(player.Character)
        end
    end
end

local function updateAllHeads()
    if not headExpanderEnabled then return end
    
    -- Cooldown, um Überlastung zu vermeiden
    local now = tick()
    if now - lastUpdate < UPDATE_INTERVAL then
        return
    end
    lastUpdate = now
    
    local headSize = 5
    if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.HeadSize then
        headSize = _G.UltimateCheat.Rayfield.Flags.HeadSize.CurrentValue
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            expandHead(player.Character, headSize)
        end
    end
end

-- Charakter hinzugefügt mit Delay
local function onCharacterAdded(character)
    task.wait(0.5)
    if headExpanderEnabled then
        local headSize = 5
        if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.HeadSize then
            headSize = _G.UltimateCheat.Rayfield.Flags.HeadSize.CurrentValue
        end
        expandHead(character, headSize)
    end
end

-- PUBLIC FUNCTIONS
function HeadExpander.toggle(state)
    headExpanderEnabled = state
    
    if state then
        -- Einmalig alle aktuellen Köpfe aktualisieren
        updateAllHeads()
        
        -- Heartbeat mit reduzierter Frequenz
        if not updateConnection then
            updateConnection = RunService.Heartbeat:Connect(updateAllHeads)
        end
        
        -- Für neue Spieler/Charaktere
        local function onPlayerAdded(player)
            if player ~= LocalPlayer then
                player.CharacterAdded:Connect(onCharacterAdded)
            end
        end
        
        -- Bestehende Spieler
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                player.CharacterAdded:Connect(onCharacterAdded)
            end
        end
        
        -- Neue Spieler
        Players.PlayerAdded:Connect(onPlayerAdded)
        
    else
        -- Ausschalten
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
        
        restoreAllHeads()
        originalHeadSizes = {}
        originalHeadCollisions = {}
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

-- INFINITE JUMP (bleibt unverändert)
local infiniteJumpEnabled = false
local infiniteJumpConnection = nil
local UserInputService = game:GetService("UserInputService")

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

-- WALK SPEED (bleibt unverändert)
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
    -- Nichts tun beim Start
end

return HeadExpander
