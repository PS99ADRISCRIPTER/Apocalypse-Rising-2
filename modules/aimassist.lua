-- modules/aimassist.lua
local AimAssist = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

local aimEnabled = false
local aiming = false
local aimConnection = nil
local currentTarget = nil
local lockedTarget = nil
local ESPCircle = nil

-- Smoothing Variablen
local lastMousePos = nil
local smoothingFactor = 0.3

function AimAssist.createFOVCircle()
    if ESPCircle then 
        pcall(function() ESPCircle:Remove() end)
    end
    
    local success, circle = pcall(function()
        local c = Drawing.new("Circle")
        c.Visible = false
        c.Thickness = 1
        c.Color = Color3.fromRGB(255, 255, 255)
        c.Transparency = 0.7
        c.Filled = false
        c.Radius = 100
        return c
    end)
    
    if success then
        ESPCircle = circle
    end
    return ESPCircle
end

function AimAssist.updateFOVCircle()
    if not ESPCircle then return end
    
    pcall(function()
        local camera = workspace.CurrentCamera
        if camera then
            ESPCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        end
        ESPCircle.Visible = aimEnabled
        if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.AimFOV then
            ESPCircle.Radius = _G.UltimateCheat.Rayfield.Flags.AimFOV.CurrentValue
        end
    end)
end

function AimAssist.findNearestPlayer()
    local closestPlayer = nil
    local closestDistance = 100
    local closestHead = nil
    
    if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.AimFOV then
        closestDistance = _G.UltimateCheat.Rayfield.Flags.AimFOV.CurrentValue
    end
    
    local camera = workspace.CurrentCamera
    if not camera then return nil, nil end
    
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        -- WICHTIG: Überspringe den lokalen Spieler
        if otherPlayer ~= LocalPlayer and otherPlayer.Character then
            local humanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            
            -- Prüfe ob Spieler tot ist
            if humanoid and humanoid.Health > 0 then
                local targetPart = nil
                
                local targetPartName = "Head"
                if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.TargetPart then
                    targetPartName = _G.UltimateCheat.Rayfield.Flags.TargetPart.CurrentOption[1]
                end
                
                if targetPartName == "Head" then
                    targetPart = otherPlayer.Character:FindFirstChild("Head")
                elseif targetPartName == "HumanoidRootPart" then
                    targetPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                elseif targetPartName == "Torso" then
                    targetPart = otherPlayer.Character:FindFirstChild("Torso") or otherPlayer.Character:FindFirstChild("UpperTorso")
                end
                
                if targetPart then
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
    end
    
    return closestPlayer, closestHead
end

function AimAssist.permanentAim()
    if not aiming then return end
    
    -- Prüfe ob lockedTarget noch gültig ist
    if lockedTarget and lockedTarget.Parent then
        local character = lockedTarget.Parent
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 and character ~= LocalPlayer.Character then
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
    
    -- Prüfe ob das Ziel der eigene Spieler ist
    local targetCharacter = currentTarget.Parent
    if targetCharacter == LocalPlayer.Character then
        currentTarget = nil
        lockedTarget = nil
        return
    end
    
    local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
    if not targetPlayer or targetPlayer == LocalPlayer then
        currentTarget = nil
        lockedTarget = nil
        return
    end
    
    local humanoid = targetCharacter:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        currentTarget = nil
        lockedTarget = nil
        return
    end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local screenPoint = camera:WorldToScreenPoint(currentTarget.Position)
    local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
    
    local currentMousePos = Vector2.new(mouse.X, mouse.Y)
    local direction = (targetPos - currentMousePos)
    
    -- Aim Speed aus den Einstellungen holen
    local speed = 0.3
    if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags and _G.UltimateCheat.Rayfield.Flags.AimSpeed then
        speed = _G.UltimateCheat.Rayfield.Flags.AimSpeed.CurrentValue
    end
    
    -- Smoothing: Nur einen Teil der Bewegung in einem Frame ausführen
    local step = direction * speed
    
    -- Begrenze maximale Bewegung pro Frame (verhindert "drehen")
    local maxStep = 15
    if step.Magnitude > maxStep then
        step = step.Unit * maxStep
    end
    
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
        if targetHead and targetPlayer ~= LocalPlayer then
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

function AimAssist.resetAimAssist()
    AimAssist.toggle(false)
    if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags then
        _G.UltimateCheat.Rayfield.Flags.AimToggle:Set(false)
        _G.UltimateCheat.Rayfield.Flags.AimSpeed:Set(0.3)
        _G.UltimateCheat.Rayfield.Flags.AimFOV:Set(100)
        _G.UltimateCheat.Rayfield.Flags.ShowFOV:Set(false)
        _G.UltimateCheat.Rayfield.Flags.TargetPart:Set({"Head"})
    end
    if ESPCircle then
        ESPCircle.Visible = false
    end
end

function AimAssist.init()
    AimAssist.createFOVCircle()
end

return AimAssist
