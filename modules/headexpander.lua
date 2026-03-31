-- modules/headexpander.lua
local HeadExpander = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local headExpanderEnabled = false
local headExpanderConnection = nil
local originalHeadSizes = {}
local originalHeadCollisions = {}

local infiniteJumpEnabled = false
local infiniteJumpConnection = nil

local walkSpeedEnabled = false
local walkSpeedConnection = nil
local normalWalkSpeed = 16
local sprintWalkSpeed = 35
local currentWalkSpeed = 16
local isSprinting = false

-- Cooldown für Head Expander Updates (reduziert CPU-Last)
local lastHeadUpdate = 0
local HEAD_UPDATE_INTERVAL = 0.5 -- Nur alle 0.5 Sekunden aktualisieren

-- HEAD EXPANDER - Optimiert
local function expandHead(character, size)
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    -- Prüfe ob sich die Größe bereits geändert hat (verhindert unnötige Setzungen)
    if head.Size == Vector3.new(size, size, size) then
        return -- Keine Änderung nötig
    end
    
    if not originalHeadSizes[character] then
        originalHeadSizes[character] = head.Size
        originalHeadCollisions[character] = head.CanCollide
    end
    
    -- Nur setzen wenn nötig
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
    
    local currentTime = tick()
    if currentTime - lastHeadUpdate < HEAD_UPDATE_INTERVAL then
        return -- Zu früh, überspringe Update
    end
    lastHeadUpdate = currentTime
    
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

-- Charakter-Hinzufügung mit Delay (verhindert Überlastung)
local function onCharacterAdded(player, character)
    task.wait(0.5) -- Warte 0.5 Sekunden bevor Head geändert wird
    if headExpanderEnabled and player ~= LocalPlayer then
        local headSize = 5
        if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.HeadSize then
            headSize = _G.UltimateCheat.Rayfield.Flags.HeadSize.CurrentValue
        end
        expandHead(character, headSize)
    end
end

function HeadExpander.toggle(state)
    headExpanderEnabled = state
    
    if state then
        -- Einmalige Initial-Update
        updateAllHeads()
        
        -- Heartbeat mit reduzierter Frequenz (nur alle 0.5 Sekunden)
        headExpanderConnection = RunService.Heartbeat:Connect(updateAllHeads)
        
        -- CharacterAdded mit Delay verbinden
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local connection
                connection = player.CharacterAdded:Connect(function(character)
                    onCharacterAdded(player, character)
                end)
                -- Speichere connection falls nötig (optional)
                if not player._headExpanderConnection then
                    player._headExpanderConnection = connection
                end
            end
        end
        
        -- Für neue Spieler
        local playerAddedConnection
        playerAddedConnection = Players.PlayerAdded:Connect(function(player)
            if player ~= LocalPlayer then
                local connection
                connection = player.CharacterAdded:Connect(function(character)
                    onCharacterAdded(player, character)
                end)
                player._headExpanderConnection = connection
            end
        end)
        _G.UltimateCheat._playerAddedConnection = playerAddedConnection
        
    else
        -- Head Expander ausschalten
        if headExpanderConnection then
            headExpanderConnection:Disconnect()
            headExpanderConnection = nil
        end
        
        -- Connections aufräumen
        for _, player in pairs(Players:GetPlayers()) do
            if player._headExpanderConnection then
                player._headExpanderConnection:Disconnect()
                player._headExpanderConnection = nil
            end
        end
        if _G.UltimateCheat and _G.UltimateCheat._playerAddedConnection then
            _G.UltimateCheat._playerAddedConnection:Disconnect()
            _G.UltimateCheat._playerAddedConnection = nil
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

-- INFINITE JUMP (unverändert)
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
