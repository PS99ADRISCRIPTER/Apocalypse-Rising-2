-- main.lua (aktualisiert)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local mouse = LocalPlayer:GetMouse()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Messages = {
    "Aim Bot activated 🎯",
    "ESP Vision active 👁️",
    "Head Expander loaded 🧠",
    "Ultimate Cheat Suite ⚡",
    "Ready to dominate 😈",
    "Secure your victory 🏆",
    "Made unstoppable 💪",
    "Cheat Engine loaded 🔧"
}
local ChosenMessage = Messages[math.random(1, #Messages)]

local Window = Rayfield:CreateWindow({
    Name = "Apocalypse Rising 2 Free Rain",
    Icon = 107904589783906,
    LoadingTitle = "Ultimate Cheat Suite",
    LoadingSubtitle = ChosenMessage,
    Theme = "Default",
    DisableRayfieldPrompts = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UltimateCheatConfigs",
        FileName = "Configuration",
    },
})

local AimTab = Window:CreateTab("Aim Assist", "target")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local PlayerTab = Window:CreateTab("Player", "user")
local SettingsTab = Window:CreateTab("Settings", "settings")

-- Module laden
local AimAssist = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/aimassist.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/esp.lua"))()
local HeadExpander = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/headexpander.lua"))()
local XRay = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/xray.lua"))()
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/ui.lua"))()

-- Globale Tabelle
_G.UltimateCheat = {
    Window = Window,
    AimTab = AimTab,
    VisualsTab = VisualsTab,
    PlayerTab = PlayerTab,
    SettingsTab = SettingsTab,
    Rayfield = Rayfield,
    Players = Players,
    LocalPlayer = LocalPlayer,
    RunService = RunService,
    UserInputService = UserInputService,
    mouse = mouse,
    STUD_TO_M = 0.28,
    PAUSED = false,
    -- Module Referenzen
    AimAssist = AimAssist,
    ESP = ESP,
    HeadExpander = HeadExpander,
    XRay = XRay
}

-- Module initialisieren
if AimAssist and AimAssist.init then AimAssist.init() end
if ESP and ESP.init then ESP.init() end
if HeadExpander and HeadExpander.init then HeadExpander.init() end
if XRay and XRay.init then XRay.init() end
if UI and UI.init then UI.init() end

-- Input Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        Rayfield:SetVisibility(not Rayfield:IsVisible())
    end
    
    if input.KeyCode == Enum.KeyCode.F5 and AimAssist then
        local newState = not AimAssist.isEnabled()
        AimAssist.toggle(newState)
        if UI and UI.updateAimToggle then UI.updateAimToggle(newState) end
    end
    
    if input.KeyCode == Enum.KeyCode.F4 and ESP then
        local newState = not ESP.isPlayerEspEnabled()
        ESP.togglePlayerESP(newState)
        if UI and UI.updatePlayerESPToggle then UI.updatePlayerESPToggle(newState) end
    end
    
    if input.KeyCode == Enum.KeyCode.H and HeadExpander then
        local newState = not HeadExpander.isEnabled()
        HeadExpander.toggle(newState)
        if UI and UI.updateHeadToggle then UI.updateHeadToggle(newState) end
    end
    
    if input.KeyCode == Enum.KeyCode.V and HeadExpander then
        local newState = not HeadExpander.isInfiniteJumpEnabled()
        HeadExpander.toggleInfiniteJump(newState)
        if UI and UI.updateInfiniteJumpToggle then UI.updateInfiniteJumpToggle(newState) end
    end
    
    if input.KeyCode == Enum.KeyCode.B and HeadExpander then
        local newState = not HeadExpander.isWalkSpeedEnabled()
        HeadExpander.toggleWalkSpeed(newState)
        if UI and UI.updateWalkSpeedToggle then UI.updateWalkSpeedToggle(newState) end
    end
    
    if input.KeyCode == Enum.KeyCode.F3 then
        _G.UltimateCheat.PAUSED = not _G.UltimateCheat.PAUSED
        print("Visuals Pause: " .. (_G.UltimateCheat.PAUSED and "ON" or "OFF"))
    end
    
    if input.KeyCode == Enum.KeyCode.F8 and XRay then
        XRay.toggle()
    end
    
    if input.KeyCode == Enum.KeyCode.F9 and ESP then
        local newState = not ESP.isVehicleEspEnabled()
        ESP.toggleVehicleESP(newState)
        if UI and UI.updateVehicleESPToggle then UI.updateVehicleESPToggle(newState) end
    end
    
    if AimAssist and AimAssist.isEnabled() and input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimAssist.startAiming()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if AimAssist and AimAssist.isEnabled() and input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimAssist.stopAiming()
    end
end)

RunService.Heartbeat:Connect(function()
    if _G.UltimateCheat.PAUSED then return end
    
    if ESP and ESP.isPlayerEspEnabled() then
        ESP.updatePlayerVisuals()
    end
    
    if ESP and ESP.isVehicleEspEnabled() then
        ESP.updateVehicleESP()
    end
    
    if AimAssist then
        AimAssist.updateFOVCircle()
    end
end)

print("==========================================")
print("Ultimate Cheat Suite successfully loaded!")
print("==========================================")
print("Controls:")
print("- RightControl: Toggle UI")
print("- F5: Toggle Aim Assist")
print("- F4: Toggle Player ESP")
print("- H: Toggle Head Expander")
print("- V: Toggle Infinite Jump")
print("- B: Toggle Walk Speed")
print("- F3: Pause All Visuals")
print("- F8: Toggle X-Ray")
print("- F9: Toggle Vehicle ESP")
print("- Mouse 2: Aim (when Aim Assist enabled)")
print("==========================================")
