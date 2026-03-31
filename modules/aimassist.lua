-- modules/aimassist.lua
local AimAssist = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- Variablen
local aimEnabled = false
local aiming = false
local aimConnection = nil
local currentTarget = nil
local lockedTarget = nil
local ESPCircle = nil

-- FOV Circle erstellen
function AimAssist.createFOVCircle()
    if ESPCircle then ESPCircle:Remove() end
    
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Thickness = 1
    circle.Color = Color3.fromRGB(255, 255, 255)
    circle.Transparency = 0.7
    circle.Filled = false
    circle.Radius = 100
    
    ESPCircle = circle
    return circle
end

function AimAssist.updateFOVCircle()
    if not ESPCircle then return end
    
    local camera = workspace.CurrentCamera
    ESPCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    ESPCircle.Visible = aimEnabled
    ESPCircle.Radius = _G.UltimateCheat.Rayfield.Flags.AimFOV and _G.UltimateCheat.Rayfield.Flags.AimFOV.CurrentValue or 100
end

function AimAssist.findNearestPlayer()
    local closestPlayer = nil
    local closestDistance = _G.UltimateCheat.Rayfield.Flags.AimFOV and _G.UltimateCheat.Rayfield.Flags.AimFOV.CurrentValue or 100
    local closestHead = nil
    
    local camera = workspace.CurrentCamera
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= LocalPlayer and otherPlayer.Character then
            local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            local targetPart = nil
            
            local targetPartName = _G.UltimateCheat.Rayfield.Flags.TargetPart and _G.UltimateCheat.Rayfield.Flags.TargetPart.CurrentOption[1] or "Head"
            if targetPartName == "Head" then
                targetPart = otherPlayer.Character:FindFirstChild("Head")
            elseif targetPartName == "HumanoidRootPart" then
                targetPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            elseif targetPartName == "Torso" then
                targetPart = otherPlayer.Character:FindFirstChild("Torso") or otherPlayer.Character:FindFirstChild("UpperTorso")
            end
            
            if humanoid and humanoid.Health > 0 and targetPart then
                local screenPoint, visible = camera:WorldToScreenPoint(targetPart.Position)
                
                if visible then
                    local playerScreenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local distance = (playerScreenPos - screenCenter).Magnitude
                    
                    if distance <= closestDistance then
                        closestDistance = distance
                        closestPlayer = otherPlayer
                        closestHead = targetPart
                    end
                end
            end
        end
    end
    
    return closestPlayer, closestHead
end

function AimAssist.permanentAim()
    if not aiming then return end
    
    if lockedTarget and lockedTarget.Parent then
        local humanoid = lockedTarget.Parent:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            currentTarget = lockedTarget
        else
            lockedTarget = nil
            currentTarget = nil
            return
        end
    elseif not currentTarget then
        local targetPlayer, targetHead = AimAssist.findNearestPlayer()
        if targetPlayer and targetHead then
            currentTarget = targetHead
            lockedTarget = targetHead
        else
            return
        end
    end
    
    if not currentTarget or not currentTarget.Parent then
        currentTarget = nil
        lockedTarget = nil
        return
    end
    
    local targetPlayer = Players:GetPlayerFromCharacter(currentTarget.Parent)
    if not targetPlayer then
        currentTarget = nil
        lockedTarget = nil
        return
    end
    
    local humanoid = currentTarget.Parent:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        currentTarget = nil
        lockedTarget = nil
        return
    end
    
    local screenPoint = workspace.CurrentCamera:WorldToScreenPoint(currentTarget.Position)
    local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
    
    local currentMousePos = Vector2.new(_G.UltimateCheat.mouse.X, _G.UltimateCheat.mouse.Y)
    local direction = (targetPos - currentMousePos)
    
    local speed = _G.UltimateCheat.Rayfield.Flags.AimSpeed and _G.UltimateCheat.Rayfield.Flags.AimSpeed.CurrentValue or 0.3
    local step = direction * speed
    
    pcall(function()
        mousemoverel(step.X, step.Y)
    end)
end

function AimAssist.toggle(state)
    aimEnabled = state
    if not state then
        aiming = false
        currentTarget = nil
        lockedTarget = nil
        if aimConnection then
            aimConnection:Disconnect()
            aimConnection = nil
        end
    end
    AimAssist.updateFOVCircle()
end

function AimAssist.isEnabled()
    return aimEnabled
end

function AimAssist.startAiming()
    aiming = true
    if not lockedTarget then
        local targetPlayer, targetHead = AimAssist.findNearestPlayer()
        if targetHead then
            lockedTarget = targetHead
            currentTarget = targetHead
        end
    end
    
    if not aimConnection then
        aimConnection = RunService.RenderStepped:Connect(AimAssist.permanentAim)
    end
end

function AimAssist.stopAiming()
    aiming = false
    lockedTarget = nil
    currentTarget = nil
    
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
end

function AimAssist.getFOVCircle()
    return ESPCircle
end

function AimAssist.init()
    AimAssist.createFOVCircle()
end

return AimAssist
