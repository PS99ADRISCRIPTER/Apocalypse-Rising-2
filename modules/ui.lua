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
            if Window then Window.ModifyTheme(Options[1]) end
        end
    })
    
    SettingsTab:CreateDivider()
    SettingsTab:CreateSection("Configuration")
    
    -- SAVE BUTTON
    SettingsTab:CreateButton({
        Name = "Save Current Settings",
        Callback = function()
            if Rayfield then 
                Rayfield:SaveConfiguration()
                print("Settings saved!")
            end
        end
    })
    
    -- LOAD BUTTON
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
            
            if _G.UltimateCheat and _G.UltimateCheat.LocalPlayer and _G.UltimateCheat.LocalPlayer.Character then
                local humanoid = _G.UltimateCheat.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = 16 end
            end
            
            print("All cheats disabled")
        end
    })
    
    SettingsTab:CreateButton({
        Name = "Reset All Settings (Defaults)",
        Callback = function()
            -- Aim Assist reset
            if AimAssist then AimAssist.resetAimAssist() end
            if aimToggleRef then aimToggleRef:Set(false) end
            
            -- ESP reset
            if ESP then
                ESP.resetPlayerESP()
                ESP.resetVehicleESP()
                if playerESPToggleRef then playerESPToggleRef:Set(false) end
                if vehicleESPToggleRef then vehicleESPToggleRef:Set(false) end
            end
            
            -- Player reset
            if HeadExpander then
                HeadExpander.resetHeadExpander()
                HeadExpander.resetInfiniteJump()
                HeadExpander.resetWalkSpeed()
                if headToggleRef then headToggleRef:Set(false) end
                if infiniteJumpToggleRef then infiniteJumpToggleRef:Set(false) end
                if walkSpeedToggleRef then walkSpeedToggleRef:Set(false) end
            end
            
            -- X-Ray reset
            if XRay and XRay.isActive() then XRay.toggle() end
            if _G.UltimateCheat and _G.UltimateCheat.Rayfield and _G.UltimateCheat.Rayfield.Flags then
                _G.UltimateCheat.Rayfield.Flags.XRayTransparency:Set(0.8)
                _G.UltimateCheat.Rayfield.Flags.CameraFOV:Set(70)
            end
            
            if workspace.CurrentCamera then
                workspace.CurrentCamera.FieldOfView = 70
            end
            
            if _G.UltimateCheat and _G.UltimateCheat.LocalPlayer and _G.UltimateCheat.LocalPlayer.Character then
                local humanoid = _G.UltimateCheat.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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
    
    -- EXECUTOR INFO (ohne CreateParagraph, falls nicht unterstützt)
    SettingsTab:CreateSection("Executor Info")
    
    -- Verwende CreateLabel statt CreateParagraph (kompatibler)
    SettingsTab:CreateLabel("Executor: " .. (_G.UltimateCheat and _G.UltimateCheat.Executor or "Unknown"))
    SettingsTab:CreateLabel("Running on: " .. (_G.UltimateCheat and _G.UltimateCheat.Executor or "Unknown"))
end
