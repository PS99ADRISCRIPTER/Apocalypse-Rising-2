-- modules/ui.lua
local UI = {}

local Rayfield = nil
local Window = nil
local AimTab = nil
local VisualsTab = nil
local PlayerTab = nil
local SettingsTab = nil

local aimToggleRef = nil
local playerESPToggleRef = nil
local vehicleESPToggleRef = nil
local headToggleRef = nil
local infiniteJumpToggleRef = nil
local walkSpeedToggleRef = nil

local AimAssist = nil
local ESP = nil
local HeadExpander = nil
local XRay = nil

function UI.createAimTab()
    if not AimTab then return end
    
    AimTab:CreateSection("Aim Assist Settings")
    
    aimToggleRef = AimTab:CreateToggle({
        Name = "Enable Aim Assist",
        CurrentValue = false,
        Flag = "AimToggle",
        Callback = function(Value)
            if AimAssist then AimAssist.toggle(Value) end
        end
    })
    
    AimTab:CreateKeybind({
        Name = "Aim Keybind",
        CurrentKeybind = "MouseButton2",
        HoldToInteract = false,
        Flag = "AimKey",
        Callback = function() end
    })
    
    AimTab:CreateKeybind({
        Name = "Aim Toggle Keybind",
        CurrentKeybind = "F5",
        HoldToInteract = false,
        Flag = "AimToggleKey",
        Callback = function() end
    })
    
    AimTab:CreateDivider()
    
    AimTab:CreateSlider({
        Name = "Aim Speed",
        Range = {0.1, 1.0},
        Increment = 0.05,
        Suffix = "x",
        CurrentValue = 0.3,
        Flag = "AimSpeed",
        Callback = function() end
    })
    
    AimTab:CreateSlider({
        Name = "Aim FOV",
        Range = {50, 300},
        Increment = 10,
        Suffix = "px",
        CurrentValue = 100,
        Flag = "AimFOV",
        Callback = function(Value)
            if AimAssist then
                local circle = AimAssist.getFOVCircle()
                if circle then circle.Radius = Value end
                AimAssist.updateFOVCircle()
            end
        end
    })
    
    AimTab:CreateToggle({
        Name = "Show FOV Circle",
        CurrentValue = false,
        Flag = "ShowFOV",
        Callback = function(Value)
            if AimAssist then
                local circle = AimAssist.getFOVCircle()
                if circle then circle.Visible = Value and AimAssist.isEnabled() end
            end
        end
    })
    
    AimTab:CreateDropdown({
        Name = "Target Body Part",
        Options = {"Head", "HumanoidRootPart", "Torso"},
        CurrentOption = {"Head"},
        MultipleOptions = false,
        Flag = "TargetPart",
        Callback = function() end
    })
    
    AimTab:CreateDivider()
    
    AimTab:CreateButton({
        Name = "Reset Aim Assist",
        Callback = function()
            if AimAssist then
                AimAssist.resetAimAssist()
                if aimToggleRef then aimToggleRef:Set(false) end
            end
        end
    })
end

function UI.createVisualsTab()
    if not VisualsTab then return end
    
    VisualsTab:CreateSection("Player ESP")
    
    playerESPToggleRef = VisualsTab:CreateToggle({
        Name = "Player ESP",
        CurrentValue = false,
        Flag = "PlayerESP",
        Callback = function(Value)
            if ESP then ESP.togglePlayerESP(Value) end
        end
    })
    
    VisualsTab:CreateKeybind({
        Name = "Player ESP Keybind",
        CurrentKeybind = "F4",
        HoldToInteract = false,
        Flag = "PlayerESPKeybind",
        Callback = function() end
    })
    
    VisualsTab:CreateToggle({
        Name = "Show Player Names",
        CurrentValue = true,
        Flag = "PlayerName",
        Callback = function(Value)
            if ESP then
                ESP.setShowPlayerNames(Value)
                if ESP.isPlayerEspEnabled() then ESP.updatePlayerVisuals() end
            end
        end
    })
    
    VisualsTab:CreateToggle({
        Name = "Show Player Distance",
        CurrentValue = true,
        Flag = "PlayerDistance",
        Callback = function(Value)
            if ESP then
                ESP.setShowPlayerDistance(Value)
                if ESP.isPlayerEspEnabled() then ESP.updatePlayerVisuals() end
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
            if ESP then
                ESP.setPlayerFillTransparency(Value)
                if ESP.isPlayerEspEnabled() then ESP.updatePlayerVisuals() end
            end
        end
    })
    
    VisualsTab:CreateColorPicker({
        Name = "Player ESP Color",
        Color = Color3.fromRGB(255, 255, 255),
        Flag = "PlayerESPColor",
        Callback = function(Value)
            if ESP then
                ESP.setPlayerColor(Value)
                if ESP.isPlayerEspEnabled() then ESP.updatePlayerVisuals() end
            end
        end
    })
    
    VisualsTab:CreateSection("Vehicle ESP")
    
    vehicleESPToggleRef = VisualsTab:CreateToggle({
        Name = "Vehicle ESP",
        CurrentValue = false,
        Flag = "VehicleESP",
        Callback = function(Value)
            if ESP then ESP.toggleVehicleESP(Value) end
        end
    })
    
    VisualsTab:CreateKeybind({
        Name = "Vehicle ESP Keybind",
        CurrentKeybind = "F9",
        HoldToInteract = false,
        Flag = "VehicleKeybind",
        Callback = function() end
    })
    
    VisualsTab:CreateToggle({
        Name = "Show Vehicle Distance",
        CurrentValue = true,
        Flag = "VehicleDistance",
        Callback = function(Value)
            if ESP then
                ESP.setShowVehicleDistance(Value)
                if ESP.isVehicleEspEnabled() then ESP.updateVehicleESP() end
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
            if ESP then
                ESP.setMaxVehicleDistance(Value)
                if ESP.isVehicleEspEnabled() then ESP.updateVehicleESP() end
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
        Callback = function() end
    })
    
    VisualsTab:CreateSlider({
        Name = "X-Ray Transparency",
        Range = {0.1, 1.0},
        Increment = 0.05,
        CurrentValue = 0.8,
        Flag = "XRayTransparency",
        Callback = function(Value)
            if XRay then XRay.setTransparency(Value) end
        end
    })
    
    VisualsTab:CreateDivider()
    
    VisualsTab:CreateButton({
        Name = "Reset Player ESP",
        Callback = function()
            if ESP then
                ESP.resetPlayerESP()
                if playerESPToggleRef then playerESPToggleRef:Set(false) end
            end
        end
    })
    
    VisualsTab:CreateButton({
        Name = "Reset Vehicle ESP",
        Callback = function()
            if ESP then
                ESP.resetVehicleESP()
                if vehicleESPToggleRef then vehicleESPToggleRef:Set(false) end
            end
        end
    })
end

function UI.createPlayerTab()
    if not PlayerTab then return end
    
    PlayerTab:CreateSection("Head Expander")
    
    headToggleRef = PlayerTab:CreateToggle({
        Name = "Enable Head Expander",
        CurrentValue = false,
        Flag = "HeadToggle",
        Callback = function(Value)
            if HeadExpander then HeadExpander.toggle(Value) end
        end
    })
    
    PlayerTab:CreateKeybind({
        Name = "Head Expander Keybind",
        CurrentKeybind = "H",
        HoldToInteract = false,
        Flag = "HeadKeybind",
        Callback = function() end
    })
    
    PlayerTab:CreateDivider()
    
    PlayerTab:CreateSlider({
        Name = "Head Size",
        Range = {2, 35},
        Increment = 0.5,
        Suffix = " studs",
        CurrentValue = 5,
        Flag = "HeadSize",
        Callback = function(Value)
            if HeadExpander then HeadExpander.updateSize() end
        end
    })
    
    PlayerTab:CreateDivider()
    
    PlayerTab:CreateSection("Infinite Jump")
    
    infiniteJumpToggleRef = PlayerTab:CreateToggle({
        Name = "Enable Infinite Jump",
        CurrentValue = false,
        Flag = "InfiniteJumpToggle",
        Callback = function(Value)
            if HeadExpander then HeadExpander.toggleInfiniteJump(Value) end
        end
    })
    
    PlayerTab:CreateKeybind({
        Name = "Infinite Jump Keybind",
        CurrentKeybind = "V",
        HoldToInteract = false,
        Flag = "InfiniteJumpKeybind",
        Callback = function() end
    })
    
    PlayerTab:CreateDivider()
    
    PlayerTab:CreateSection("Walk Speed")
    
    walkSpeedToggleRef = PlayerTab:CreateToggle({
        Name = "Enable Walk Speed",
        CurrentValue = false,
        Flag = "WalkSpeedToggle",
        Callback = function(Value)
            if HeadExpander then HeadExpander.toggleWalkSpeed(Value) end
        end
    })
    
    PlayerTab:CreateSlider({
        Name = "Normal Walk Speed",
        Range = {16, 50},
        Increment = 1,
        Suffix = " studs/sec",
        CurrentValue = 16,
        Flag = "NormalWalkSpeed",
        Callback = function(Value)
            if HeadExpander then HeadExpander.setNormalWalkSpeed(Value) end
        end
    })
    
    PlayerTab:CreateSlider({
        Name = "Sprint Walk Speed",
        Range = {25, 80},
        Increment = 1,
        Suffix = " studs/sec",
        CurrentValue = 35,
        Flag = "SprintWalkSpeed",
        Callback = function(Value)
            if HeadExpander then HeadExpander.setSprintWalkSpeed(Value) end
        end
    })
    
    PlayerTab:CreateDivider()
    PlayerTab:CreateSection("Reset")
    
    PlayerTab:CreateButton({
        Name = "Reset Head Expander",
        Callback = function()
            if HeadExpander then
                HeadExpander.resetHeadExpander()
                if headToggleRef then headToggleRef:Set(false) end
            end
        end
    })
    
    PlayerTab:CreateButton({
        Name = "Reset Infinite Jump",
        Callback = function()
            if HeadExpander then
                HeadExpander.resetInfiniteJump()
                if infiniteJumpToggleRef then infiniteJumpToggleRef:Set(false) end
            end
        end
    })
    
    PlayerTab:CreateButton({
        Name = "Reset Walk Speed",
        Callback = function()
            if HeadExpander then
                HeadExpander.resetWalkSpeed()
                if walkSpeedToggleRef then walkSpeedToggleRef:Set(false) end
            end
        end
    })
    
    PlayerTab:CreateButton({
        Name = "Reset All Player Settings",
        Callback = function()
            if HeadExpander then
                HeadExpander.resetHeadExpander()
                HeadExpander.resetInfiniteJump()
                HeadExpander.resetWalkSpeed()
                if headToggleRef then headToggleRef:Set(false) end
                if infiniteJumpToggleRef then infiniteJumpToggleRef:Set(false) end
                if walkSpeedToggleRef then walkSpeedToggleRef:Set(false) end
            end
        end
    })
end

function UI.createSettingsTab()
    if not SettingsTab then return end
    
    SettingsTab:CreateSection("UI Settings")
    
    SettingsTab:CreateKeybind({
        Name = "Toggle UI",
        CurrentKeybind = "RightControl",
        HoldToInteract = false,
        Flag = "UIKeybind",
        Callback = function() end
    })
    
    SettingsTab:CreateDropdown({
        Name = "UI Theme",
        Options = {"Default", "AmberGlow", "Amethyst", "Bloom", "DarkBlue", "Green", "Light", "Ocean", "Serenity"},
        CurrentOption = {"Default"},
        MultipleOptions = false,
        Flag = "UITheme",
        Callback = function(Options)
            if Window then Window.ModifyTheme(Options[1]) end
        end
    })
    
    SettingsTab:CreateDivider()
    SettingsTab:CreateSection("Configuration")
    
    SettingsTab:CreateButton({
        Name = "Save Current Settings",
        Callback = function()
            if Rayfield then 
                Rayfield:SaveConfiguration()
                print("Settings saved!")
            end
        end
    })
    
    SettingsTab:CreateButton({
        Name = "Load Saved Settings",
        Callback = function()
            if Rayfield then 
                Rayfield:LoadConfiguration()
                print("Settings loaded!")
            end
        end
    })
    
    SettingsTab:CreateDivider()
    SettingsTab:CreateSection("Reset Everything")
    
    SettingsTab:CreateButton({
        Name = "Disable All Cheats",
        Callback = function()
            if AimAssist then AimAssist.toggle(false) end
            if ESP then
                ESP.togglePlayerESP(false)
                ESP.toggleVehicleESP(false)
            end
            if HeadExpander then
                HeadExpander.toggle(false)
                HeadExpander.toggleInfiniteJump(false)
                HeadExpander.toggleWalkSpeed(false)
            end
            if XRay and XRay.isActive() then XRay.toggle() end
            
            if aimToggleRef then aimToggleRef:Set(false) end
            if playerESPToggleRef then playerESPToggleRef:Set(false) end
            if vehicleESPToggleRef then vehicleESPToggleRef:Set(false) end
            if headToggleRef then headToggleRef:Set(false) end
            if infiniteJumpToggleRef then infiniteJumpToggleRef:Set(false) end
            if walkSpeedToggleRef then walkSpeedToggleRef:Set(false) end
            
            if AimAssist then
                local circle = AimAssist.getFOVCircle()
                if circle then circle.Visible = false end
            end
            
            if workspace.CurrentCamera then
                workspace.CurrentCamera.FieldOfView = 70
            end
            
            if LocalPlayer and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = 16 end
            end
            
            print("All cheats disabled")
        end
    })
    
    SettingsTab:CreateButton({
        Name = "Reset All Settings (Defaults)",
        Callback = function()
            if AimAssist then AimAssist.resetAimAssist() end
            if aimToggleRef then aimToggleRef:Set(false) end
            
            if ESP then
                ESP.resetPlayerESP()
                ESP.resetVehicleESP()
                if playerESPToggleRef then playerESPToggleRef:Set(false) end
                if vehicleESPToggleRef then vehicleESPToggleRef:Set(false) end
            end
            
            if HeadExpander then
                HeadExpander.resetHeadExpander()
                HeadExpander.resetInfiniteJump()
                HeadExpander.resetWalkSpeed()
                if headToggleRef then headToggleRef:Set(false) end
                if infiniteJumpToggleRef then infiniteJumpToggleRef:Set(false) end
                if walkSpeedToggleRef then walkSpeedToggleRef:Set(false) end
            end
            
            if XRay and XRay.isActive() then XRay.toggle() end
            if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags then
                _G.UltimateCheat.Rayfield.Flags.XRayTransparency:Set(0.8)
                _G.UltimateCheat.Rayfield.Flags.CameraFOV:Set(70)
            end
            
            if workspace.CurrentCamera then
                workspace.CurrentCamera.FieldOfView = 70
            end
            
            if LocalPlayer and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = 16 end
            end
            
            print("All settings reset to default")
        end
    })
    
    SettingsTab:CreateButton({
        Name = "Close UI",
        Callback = function()
            if Rayfield then Rayfield:Destroy() end
        end
    })
    
    SettingsTab:CreateDivider()
    SettingsTab:CreateSection("Executor Info")
    
    SettingsTab:CreateLabel("Executor: " .. (_G.UltimateCheat and _G.UltimateCheat.Executor or "Unknown"))
end

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
    if not _G.UltimateCheat then 
        warn("_G.UltimateCheat nicht gefunden")
        return 
    end
    
    Rayfield = _G.UltimateCheat.Rayfield
    Window = _G.UltimateCheat.Window
    AimTab = _G.UltimateCheat.AimTab
    VisualsTab = _G.UltimateCheat.VisualsTab
    PlayerTab = _G.UltimateCheat.PlayerTab
    SettingsTab = _G.UltimateCheat.SettingsTab
    
    AimAssist = _G.UltimateCheat.AimAssist
    ESP = _G.UltimateCheat.ESP
    HeadExpander = _G.UltimateCheat.HeadExpander
    XRay = _G.UltimateCheat.XRay
    LocalPlayer = _G.UltimateCheat.LocalPlayer
    
    -- Prüfen ob Tabs existieren
    if not AimTab or not VisualsTab or not PlayerTab or not SettingsTab then
        warn("Tabs sind nil in UI.init")
        return
    end
    
    UI.createAimTab()
    UI.createVisualsTab()
    UI.createPlayerTab()
    UI.createSettingsTab()
    
    print("UI erfolgreich initialisiert")
end

return UI
