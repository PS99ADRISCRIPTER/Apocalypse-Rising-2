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
                restoreHead(player.Character
