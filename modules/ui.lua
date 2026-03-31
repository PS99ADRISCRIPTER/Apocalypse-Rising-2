-- modules/ui.lua
local UI = {}
local Rayfield = _G.UltimateCheat.Rayfield
local Window = _G.UltimateCheat.Window
local AimTab = _G.UltimateCheat.AimTab
local VisualsTab = _G.UltimateCheat.VisualsTab
local PlayerTab = _G.UltimateCheat.PlayerTab
local SettingsTab = _G.UltimateCheat.SettingsTab

-- Referenzen auf Toggles (für Updates)
local aimToggleRef = nil
local playerESPToggleRef = nil
local vehicleESPToggleRef = nil
local headToggleRef = nil
local infiniteJumpToggleRef = nil
local walkSpeedToggleRef = nil

-- AIM ASSIST UI
function UI.createAimTab()
    AimTab:CreateSection("Aim Assist Settings")
    
    aimToggleRef = AimTab:CreateToggle({
        Name = "Enable Aim Assist",
        CurrentValue = false,
        Flag = "AimToggle",
        Callback = function(Value)
            local AimAssist = require(script.Parent.modules.aimassist)
            AimAssist.toggle(Value)
        end
    })
    
    AimTab:CreateKeybind({
        Name = "Aim Keybind",
        CurrentKeybind = "MouseButton2",
        HoldToInteract = false,
        Flag = "AimKey",
        Callback = function(Key) end
    })
    
    AimTab:CreateKeybind({
        Name = "Aim Toggle Keybind",
        CurrentKeybind = "F5",
        HoldToInteract = false,
        Flag = "AimToggleKey",
        Callback = function(Key) end
    })
    
    AimTab:CreateDivider()
    
    AimTab:CreateSlider({
        Name = "Aim Speed",
        Range = {0.1, 1.0},
        Increment = 0.05,
        Suffix = "x",
        CurrentValue = 0.3,
        Flag = "AimSpeed",
        Callback = function(Value) end
    })
    
    AimTab:CreateSlider({
        Name = "Aim FOV",
        Range = {50, 300},
        Increment = 10,
        Suffix = "px",
        CurrentValue = 100,
        Flag = "AimFOV",
        Callback = function(Value)
            local AimAssist = require(script.Parent.modules.aimassist)
            local circle = AimAssist.getFOVCircle()
            if circle then
                circle.Radius = Value
            end
            AimAssist.updateFOVCircle()
        end
    })
    
    AimTab:CreateToggle({
        Name = "Show FOV Circle",
        CurrentValue = false,
        Flag = "ShowFOV",
        Callback = function(Value)
            local AimAssist = require(script.Parent.modules.aimassist)
            local circle = AimAssist.getFOVCircle()
            if circle then
                circle.Visible = Value and AimAssist.isEnabled()
            end
        end
    })
    
    AimTab:CreateDropdown({
        Name = "Target Body Part",
        Options = {"Head", "HumanoidRootPart", "Torso"},
        CurrentOption = {"Head"},
        MultipleOptions = false,
        Flag = "TargetPart",
        Callback = function(Options) end
    })
    
    AimTab:CreateDivider()
    
    AimTab:CreateButton({
        Name = "Reset Aim Assist",
        Callback = function()
            local AimAssist = require(script.Parent.modules.aimassist)
            AimAssist.toggle(false)
            aimToggleRef:Set(false)
            local circle = AimAssist.getFOVCircle()
            if circle then
                circle.Visible = false
            end
        end
    })
end

-- VISUALS/ESP UI
function UI.createVisualsTab()
    VisualsTab:CreateSection("Player ESP")
    
    playerESPToggleRef = VisualsTab:CreateToggle({
        Name = "Player ESP",
        CurrentValue = false,
        Flag = "PlayerESP",
        Callback = function(Value)
            local ESP = require(script.Parent.modules.esp)
            ESP.togglePlayerESP(Value)
        end
    })
    
    VisualsTab:CreateKeybind({
        Name = "Player ESP Keybind",
        CurrentKeybind = "F4",
        HoldToInteract = false,
        Flag = "PlayerESPKeybind",
        Callback = function(Key) end
    })
    
    VisualsTab:CreateToggle({
        Name = "Show Player Names",
        CurrentValue = true,
        Flag = "PlayerName",
        Callback = function(Value)
            local ESP = require(script.Parent.modules.esp)
            ESP.setShowPlayerNames(Value)
            if ESP.isPlayerEspEnabled() then
                ESP.updatePlayerVisuals()
            end
        end
    })
    
    VisualsTab:CreateToggle({
        Name = "Show Player Distance",
        CurrentValue = true,
        Flag = "PlayerDistance",
        Callback = function(Value)
            local ESP = require(script.Parent.modules.esp)
            ESP.setShowPlayerDistance(Value)
            if ESP.isPlayerEspEnabled() then
                ESP.updatePlayerVisuals()
            end
        end
    })
    
    VisualsTab:CreateSlider({
        Name = "Player Fill Transparency",
        Range = {0, 1},
        Increment = 0.05,
        CurrentValue = 0.5,
        Flag = "PlayerFillTransparency",
        Callback = function(Value)
            local ESP = require(script.Parent.modules.esp)
            ESP.setPlayerFillTransparency(Value)
            if ESP.isPlayerEspEnabled() then
                ESP.updatePlayerVisuals()
            end
        end
    })
    
    VisualsTab:CreateColorPicker({
        Name = "Player ESP Color",
        Color = Color3.fromRGB(255, 255, 255),
        Flag = "PlayerESPColor",
        Callback = function(Value)
            local ESP = require(script.Parent.modules.esp)
            ESP.setPlayerColor(Value)
            if ESP.isPlayerEspEnabled() then
                ESP.updatePlayerVisuals()
            end
        end
    })
    
    VisualsTab:CreateSection("Vehicle ESP")
    
    vehicleESPToggleRef = VisualsTab:CreateToggle({
        Name = "Vehicle ESP",
        CurrentValue = false,
        Flag = "VehicleESP",
        Callback = function(Value)
            local ESP = require(script.Parent.modules.esp)
            ESP.toggleVehicleESP(Value)
        end
    })
    
    VisualsTab:CreateKeybind({
        Name = "Vehicle ESP Keybind",
        CurrentKeybind = "F9",
        HoldToInteract = false,
        Flag = "VehicleKeybind",
        Callback = function(Key) end
    })
    
    VisualsTab:CreateToggle({
        Name = "Show Vehicle Distance",
        CurrentValue = true,
        Flag = "VehicleDistance",
        Callback = function(Value)
            local ESP = require(script.Parent.modules.esp)
            ESP.setShowVehicleDistance(Value)
            if ESP.isVehicleEspEnabled() then
                ESP.updateVehicleESP()
            end
        end
    })
    
    VisualsTab:CreateSlider({
        Name = "Max Vehicle Distance",
        Range = {50, 5000},
        Increment = 50,
        Suffix = " studs",
        CurrentValue = 500,
        Flag = "VehicleMaxDistance",
        Callback = function(Value)
            local ESP = require(script.Parent.modules.esp)
            ESP.setMaxVehicleDistance(Value)
            if ESP.isVehicleEspEnabled() then
                ESP.updateVehicleESP()
            end
        end
    })
    
    VisualsTab:CreateSection("Camera")
    
    VisualsTab:CreateSlider({
        Name = "Camera FOV",
        Range = {70, 120},
        Increment = 1,
        Suffix = "°",
        CurrentValue = 70,
        Flag = "CameraFOV",
        Callback = function(Value)
            if workspace.CurrentCamera then
                workspace.CurrentCamera.FieldOfView = Value
            end
        end
    })
    
    VisualsTab:CreateSection("X-Ray")
    
    VisualsTab:CreateKeybind({
        Name = "X-Ray Toggle Keybind",
        CurrentKeybind = "F8",
        HoldToInteract = false,
        Flag = "XRayKeybind",
        Callback = function(Key) end
    })
    
    VisualsTab:CreateSlider({
        Name = "X-Ray Transparency",
        Range = {0.1, 1.0},
        Increment = 0.05,
        CurrentValue = 0.8,
        Flag = "XRayTransparency",
        Callback = function(Value)
            local XRay = require(script.Parent.modules.xray)
            XRay.setTransparency(Value)
        end
    })
    
    VisualsTab:CreateDivider()
    
    VisualsTab:CreateButton({
        Name = "Reset Visuals",
        Callback = function()
            local ESP = require(script.Parent.modules.esp)
            ESP.togglePlayerESP(false)
            ESP.toggleVehicleESP(false)
            playerESPToggleRef:Set(false)
            vehicleESPToggleRef:Set(false)
            
            if workspace.CurrentCamera then
                workspace.CurrentCamera.FieldOfView = 70
            end
        end
    })
end

-- PLAYER TAB
function UI.createPlayerTab()
    PlayerTab:CreateSection("Head Expander")
    
    headToggleRef = PlayerTab:CreateToggle({
        Name = "Enable Head Expander",
        CurrentValue = false,
        Flag = "HeadToggle",
        Callback = function(Value)
            local HeadExpander = require(script.Parent.modules.headexpander)
            HeadExpander.toggle(Value)
        end
    })
    
    PlayerTab:CreateKeybind({
        Name = "Head Expander Keybind",
        CurrentKeybind = "H",
        HoldToInteract = false,
        Flag = "HeadKeybind",
        Callback = function(Key) end
    })
    
    PlayerTab:CreateDivider()
    
    PlayerTab:CreateSlider({
        Name = "Head Size",
        Range = {2, 20},
        Increment = 0.5,
        Suffix = " studs",
        CurrentValue = 5,
        Flag = "HeadSize",
        Callback = function(Value)
            local HeadExpander = require(script.Parent.modules.headexpander)
            HeadExpander.updateSize()
        end
    })
    
    PlayerTab:CreateDivider()
    
    PlayerTab:CreateSection("Infinite Jump")
    
    infiniteJumpToggleRef = PlayerTab:CreateToggle({
        Name = "Enable Infinite Jump",
        CurrentValue = false,
        Flag = "InfiniteJumpToggle",
        Callback = function(Value)
            local HeadExpander = require(script.Parent.modules.headexpander)
            HeadExpander.toggleInfiniteJump(Value)
        end
    })
    
    PlayerTab:CreateKeybind({
        Name = "Infinite Jump Keybind",
        CurrentKeybind = "V",
        HoldToInteract = false,
        Flag = "InfiniteJumpKeybind",
        Callback = function(Key) end
    })
    
    PlayerTab:CreateDivider()
    
    PlayerTab:CreateSection("Walk Speed")
    
    walkSpeedToggleRef = PlayerTab:CreateToggle({
        Name = "Enable Walk Speed",
        CurrentValue = false,
        Flag = "WalkSpeedToggle",
        Callback = function(Value)
            local HeadExpander = require(script.Parent.modules.headexpander)
            HeadExpander.toggleWalkSpeed(Value)
        end
    })
    
    PlayerTab:CreateSlider({
        Name = "Normal Walk Speed",
        Range = {16, 35},
        Increment = 1,
        Suffix = " studs/sec",
        CurrentValue = 16,
        Flag = "NormalWalkSpeed",
        Callback = function(Value)
            local HeadExpander = require(script.Parent.modules.headexpander)
            HeadExpander.setNormalWalkSpeed(Value)
        end
    })
    
    PlayerTab:CreateSlider({
        Name = "Sprint Walk Speed",
        Range = {25, 35},
        Increment = 1,
        Suffix = " studs/sec",
        CurrentValue = 35,
        Flag = "SprintWalkSpeed",
        Callback = function(Value)
            local HeadExpander = require(script.Parent.modules.headexpander)
            HeadExpander.setSprintWalkSpeed(Value)
        end
    })
    
    PlayerTab:CreateDivider()
    PlayerTab:CreateSection("Reset")
    
    PlayerTab:CreateButton({
        Name = "Reset Head Expander",
        Callback = function()
            local HeadExpander = require(script.Parent.modules.headexpander)
            HeadExpander.toggle(false)
            headToggleRef:Set(false)
        end
    })
    
    PlayerTab:CreateButton({
        Name = "Reset Infinite Jump",
        Callback = function()
            local HeadExpander = require(script.Parent.modules.headexpander)
            HeadExpander.toggleInfiniteJump(false)
            infiniteJumpToggleRef:Set(false)
        end
    })
    
    PlayerTab:CreateButton({
        Name = "Reset Walk Speed",
        Callback = function()
            local HeadExpander = require(script.Parent.modules.headexpander)
            HeadExpander.toggleWalkSpeed(false)
            walkSpeedToggleRef:Set(false)
        end
    })
end

-- SETTINGS TAB
function UI.createSettingsTab()
    SettingsTab:CreateSection("UI Settings")
    
    SettingsTab:CreateKeybind({
        Name = "Toggle UI",
        CurrentKeybind = "RightControl",
        HoldToInteract = false,
        Flag = "UIKeybind",
        Callback = function(Key) end
    })
    
    SettingsTab:CreateDropdown({
        Name = "UI Theme",
        Options = {"Default", "AmberGlow", "Amethyst", "Bloom", "DarkBlue", "Green", "Light", "Ocean", "Serenity"},
        CurrentOption = {"Default"},
        MultipleOptions = false,
        Flag = "UITheme",
        Callback = function(Options)
            Window.ModifyTheme(Options[1])
        end
    })
    
    SettingsTab:CreateDivider()
    SettingsTab:CreateSection("Configuration")
    
    SettingsTab:CreateButton({
        Name = "Save All Settings",
        Callback = function()
            Rayfield:LoadConfiguration()
        end
    })
    
    SettingsTab:CreateButton({
        Name = "Load All Settings",
        Callback = function()
            Rayfield:LoadConfiguration()
        end
    })
    
    SettingsTab:CreateDivider()
    
    SettingsTab:CreateButton({
        Name = "Disable All Cheats",
        Callback = function()
            local AimAssist = require(script.Parent.modules.aimassist)
            local ESP = require(script.Parent.modules.esp)
            local HeadExpander = require(script.Parent.modules.headexpander)
            local XRay = require(script.Parent.modules.xray)
            
            AimAssist.toggle(false)
            ESP.togglePlayerESP(false)
            ESP.toggleVehicleESP(false)
            HeadExpander.toggle(false)
            HeadExpander.toggleInfiniteJump(false)
            HeadExpander.toggleWalkSpeed(false)
            
            aimToggleRef:Set(false)
            playerESPToggleRef:Set(false)
            vehicleESPToggleRef:Set(false)
            headToggleRef:Set(false)
            infiniteJumpToggleRef:Set(false)
            walkSpeedToggleRef:Set(false)
            
            local circle = AimAssist.getFOVCircle()
            if circle then
                circle.Visible = false
            end
            
            if XRay.isActive() then
                XRay.toggle()
            end
            
            if workspace.CurrentCamera then
                workspace.CurrentCamera.FieldOfView = 70
            end
            
            if _G.UltimateCheat.LocalPlayer.Character then
                local humanoid = _G.UltimateCheat.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end
            
            print("All cheats disabled")
        end
    })
    
    SettingsTab:CreateButton({
        Name = "Close UI",
        Callback = function()
            Rayfield:Destroy()
        end
    })
end

-- UI Update Funktionen (für Keybinds)
function UI.updateAimToggle(state)
    if aimToggleRef then aimToggleRef:Set(state) end
end

function UI.updatePlayerESPToggle(state)
    if playerESPToggleRef then playerESPToggleRef:Set(state) end
end

function UI.updateVehicleESPToggle(state)
    if vehicleESPToggleRef then vehicleESPToggleRef:Set(state) end
end

function UI.updateHeadToggle(state)
    if headToggleRef then headToggleRef:Set(state) end
end

function UI.updateInfiniteJumpToggle(state)
    if infiniteJumpToggleRef then infiniteJumpToggleRef:Set(state) end
end

function UI.updateWalkSpeedToggle(state)
    if walkSpeedToggleRef then walkSpeedToggleRef:Set(state) end
end

function UI.init()
    UI.createAimTab()
    UI.createVisualsTab()
    UI.createPlayerTab()
    UI.createSettingsTab()
    
    Rayfield:LoadConfiguration()
end

return UI
