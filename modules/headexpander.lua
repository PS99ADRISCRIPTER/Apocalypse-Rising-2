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

local function expandHead(character, size)
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    if not originalHeadSizes[character] then
        originalHeadSizes[character] = head.Size
        originalHeadCollisions[character] = head.CanCollide
    end
    
    head.Size = Vector3.new(size, size, size)
    head.CanCollide = true
end

local function restoreHead(character)
    if not character then return end
    
    if originalHeadSizes[character] then
        local head = character:FindFirstChild("Head")
        if head then
            head.Size = originalHeadSizes[character]
            head.CanCollide = originalHeadCollisions[character] or false
        end
        originalHeadSizes[character] = nil
        originalHeadCollisions[character] = nil
    end
end

local function updateAllHeads()
    if not headExpanderEnabled then return end
    
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

function HeadExpander.toggle(state)
    headExpanderEnabled = state
    
    if state then
        updateAllHeads()
        headExpanderConnection = RunService.Heartbeat:Connect(updateAllHeads)
        
        for _, player in pairs(Players:GetPlayers()) do
            player.CharacterAdded:Connect(function(character)
                task.wait(0.1)
                if headExpanderEnabled and player ~= LocalPlayer then
                    local headSize = 5
                    if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.HeadSize then
                        headSize = _G.UltimateCheat.Rayfield.Flags.HeadSize.CurrentValue
                    end
                    expandHead(character, headSize)
                end
            end)
        end
    else
        if headExpanderConnection then
            headExpanderConnection:Disconnect()
            headExpanderConnection = nil
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                restoreHead(player.Character)
            end
        end
        
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

function HeadExpander.toggleInfiniteJump(state)
    infiniteJumpEnabled = state
    
    if state then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState("Jumping")
                end
            end
        end)
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
        
        walkSpeedConnection = RunService.Heartbeat:Connect(updateWalkSpeed)
        
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
    end
end

function HeadExpander.setSprintWalkSpeed(speed)
    sprintWalkSpeed = speed
    if isSprinting and walkSpeedEnabled then
        currentWalkSpeed = speed
    end
end

function HeadExpander.init()
end

return HeadExpander
