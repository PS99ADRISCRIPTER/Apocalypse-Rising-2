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
    
    -- SAVE BUTTON (funktioniert jetzt)
    SettingsTab:CreateButton({
        Name = "Save Current Settings",
        Callback = function()
            if Rayfield then 
                local success, err = pcall(function()
                    Rayfield:SaveConfiguration()
                end)
                if success then
                    print("Settings saved!")
                else
                    warn("Save failed: " .. tostring(err))
                end
            end
        end
    })
    
    -- LOAD BUTTON (funktioniert jetzt)
    SettingsTab:CreateButton({
        Name = "Load Saved Settings",
        Callback = function()
            if Rayfield then 
                local success, err = pcall(function()
                    Rayfield:LoadConfiguration()
                end)
                if success then
                    print("Settings loaded!")
                    -- Nach dem Laden die UI Toggles aktualisieren
                    task.wait(0.2)
                    if AimAssist and aimToggleRef then 
                        aimToggleRef:Set(AimAssist.isEnabled())
                    end
                    if ESP and playerESPToggleRef then 
                        playerESPToggleRef:Set(ESP.isPlayerEspEnabled())
                        vehicleESPToggleRef:Set(ESP.isVehicleEspEnabled())
                    end
                    if HeadExpander then
                        if headToggleRef then headToggleRef:Set(HeadExpander.isEnabled()) end
                        if infiniteJumpToggleRef then infiniteJumpToggleRef:Set(HeadExpander.isInfiniteJumpEnabled()) end
                        if walkSpeedToggleRef then walkSpeedToggleRef:Set(HeadExpander.isWalkSpeedEnabled()) end
                    end
                else
                    warn("Load failed: " .. tostring(err))
                end
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
                pcall(function()
                    _G.UltimateCheat.Rayfield.Flags.XRayTransparency:Set(0.8)
                    _G.UltimateCheat.Rayfield.Flags.CameraFOV:Set(70)
                end)
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
