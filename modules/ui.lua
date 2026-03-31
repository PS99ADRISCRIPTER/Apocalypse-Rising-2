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
    
    -- SAVE BUTTON (speichert ALLE aktuellen Einstellungen)
    SettingsTab:CreateButton({
        Name = "Save Current Settings",
        Callback = function()
            if Rayfield then 
                Rayfield:SaveConfiguration()
                print("Settings saved!")
            end
        end
    })
    
    -- LOAD BUTTON (lädt gespeicherte Einstellungen)
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
    
    -- ... rest bleibt gleich ...
end
