-- main.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local mouse = LocalPlayer:GetMouse()

-- Module laden
local AimAssist = require(script.modules.aimassist)
local ESP = require(script.modules.esp)
local HeadExpander = require(script.modules.headexpander)
local XRay = require(script.modules.xray)
local UI = require(script.modules.ui)

-- Rayfield UI Load
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Messages für Loading Screen
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

-- Fenster erstellen
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

-- Tabs erstellen
local AimTab = Window:CreateTab("Aim Assist", "target")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local PlayerTab = Window:CreateTab("Player", "user")
local SettingsTab = Window:CreateTab("Settings", "settings")

-- Globale Variablen (werden von Modulen verwendet)
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
    PAUSED = false
}

-- Module initialisieren
AimAssist.init()
ESP.init()
HeadExpander.init()
XRay.init()
UI.init()

-- Input Handler (globale Tastenkombinationen)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- UI Toggle
    if input.KeyCode == Enum.KeyCode.RightControl then
        Rayfield:SetVisibility(not Rayfield:IsVisible())
    end
    
    -- Aim Assist Toggle (F5)
    if input.KeyCode == Enum.KeyCode.F5 then
        local newState = not AimAssist.isEnabled()
        AimAssist.toggle(newState)
        UI.updateAimToggle(newState)
    end
    
    -- Player ESP Toggle (F4)
    if input.KeyCode == Enum.KeyCode.F4 then
        local newState = not ESP.isPlayerEspEnabled()
        ESP.togglePlayerESP(newState)
        UI.updatePlayerESPToggle(newState)
    end
    
    -- Head Expander Toggle (H)
    if input.KeyCode == Enum.KeyCode.H then
        local newState = not HeadExpander.isEnabled()
        HeadExpander.toggle(newState)
        UI.updateHeadToggle(newState)
    end
    
    -- Infinite Jump Toggle (V)
    if input.KeyCode == Enum.KeyCode.V then
        local newState = not HeadExpander.isInfiniteJumpEnabled()
        HeadExpander.toggleInfiniteJump(newState)
        UI.updateInfiniteJumpToggle(newState)
    end
    
    -- Walk Speed Toggle (B)
    if input.KeyCode == Enum.KeyCode.B then
        local newState = not HeadExpander.isWalkSpeedEnabled()
        HeadExpander.toggleWalkSpeed(newState)
        UI.updateWalkSpeedToggle(newState)
    end
    
    -- Pause Visuals (F3)
    if input.KeyCode == Enum.KeyCode.F3 then
        _G.UltimateCheat.PAUSED = not _G.UltimateCheat.PAUSED
        print("Visuals Pause: " .. (_G.UltimateCheat.PAUSED and "ON" or "OFF"))
    end
    
    -- X-Ray Toggle (F8)
    if input.KeyCode == Enum.KeyCode.F8 then
        XRay.toggle()
    end
    
    -- Vehicle ESP Toggle (F9)
    if input.KeyCode == Enum.KeyCode.F9 then
        local newState = not ESP.isVehicleEspEnabled()
        ESP.toggleVehicleESP(newState)
        UI.updateVehicleESPToggle(newState)
    end
    
    -- Aim aktivieren (Maus-Taste 2)
    if AimAssist.isEnabled() and input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimAssist.startAiming()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if AimAssist.isEnabled() and input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimAssist.stopAiming()
    end
end)

-- Update Loops
RunService.Heartbeat:Connect(function()
    if _G.UltimateCheat.PAUSED then return end
    
    if ESP.isPlayerEspEnabled() then
        ESP.updatePlayerVisuals()
    end
    
    if ESP.isVehicleEspEnabled() then
        ESP.updateVehicleESP()
    end
    
    AimAssist.updateFOVCircle()
end)

print("==========================================")
print("Ultimate Cheat Suite successfully loaded!")
print("==========================================")
