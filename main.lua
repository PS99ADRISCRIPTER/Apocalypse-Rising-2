-- main.lua
-- Anti-Double-Load: Altes Skript beenden
if _G.UltimateCheat and _G.UltimateCheat.Running then
    if _G.UltimateCheat.AimAssist then _G.UltimateCheat.AimAssist.toggle(false) end
    if _G.UltimateCheat.ESP then
        _G.UltimateCheat.ESP.togglePlayerESP(false)
        _G.UltimateCheat.ESP.toggleVehicleESP(false)
    end
    if _G.UltimateCheat.HeadExpander then
        _G.UltimateCheat.HeadExpander.toggle(false)
        _G.UltimateCheat.HeadExpander.toggleInfiniteJump(false)
        _G.UltimateCheat.HeadExpander.toggleWalkSpeed(false)
    end
    if _G.UltimateCheat.XRay and _G.UltimateCheat.XRay.isActive() then
        _G.UltimateCheat.XRay.toggle()
    end
    if _G.UltimateCheat.Rayfield then
        _G.UltimateCheat.Rayfield:Destroy()
    end
    wait(0.5)
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local mouse = LocalPlayer:GetMouse()

-- Executor Erkennung
local ExecutorName = "Unknown Executor"
pcall(function()
    local name = getexecutorname()
    if name and name ~= "" then ExecutorName = name end
end)

-- Rayfield UI laden
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Messages = {
    "Playing with " .. ExecutorName .. " 🎯",
    "Running on " .. ExecutorName .. " 👁️",
    "Loaded by " .. ExecutorName .. " 🧠",
    ExecutorName .. " Edition ⚡",
    "Ready to dominate 😈",
    "Secure your victory 🏆",
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
        Enabled = false, -- AUTO-LOAD AUSGESCHALTET!
        FolderName = "UltimateCheatConfigs",
        FileName = "Configuration",
    },
})

local AimTab = Window:CreateTab("Aim Assist", "target")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local PlayerTab = Window:CreateTab("Player", "user")
local SettingsTab = Window:CreateTab("Settings", "settings")

-- ========== SEQUENTIELLES MODUL-LADEN ==========
print("Lade Module...")

-- 1. AimAssist laden
local AimAssist = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/aimassist.lua"))()
print("[1/5] AimAssist geladen")
task.wait(0.1)

-- 2. ESP laden
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/esp.lua"))()
print("[2/5] ESP geladen")
task.wait(0.1)

-- 3. HeadExpander laden
local HeadExpander = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/headexpander.lua"))()
print("[3/5] HeadExpander geladen")
task.wait(0.1)

-- 4. XRay laden
local XRay = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/xray.lua"))()
print("[4/5] XRay geladen")
task.wait(0.1)

-- 5. UI laden (als letztes)
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/ui.lua"))()
print("[5/5] UI geladen")

-- Globale Tabelle
_G.UltimateCheat = {
    Running = true,
    Executor = ExecutorName,
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
    AimAssist = AimAssist,
    ESP = ESP,
    HeadExpander = HeadExpander,
    XRay = XRay
}

-- ========== MODULE INITIALISIEREN (ALLE STANDARD = AUS) ==========
print("Initialisiere Module (alle Cheats sind AUS)...")

if AimAssist and AimAssist.init then 
    AimAssist.init() 
    AimAssist.toggle(false)
end
if ESP and ESP.init then 
    ESP.init() 
    ESP.togglePlayerESP(false)
    ESP.toggleVehicleESP(false)
end
if HeadExpander and HeadExpander.init then 
    HeadExpander.init() 
    HeadExpander.toggle(false)
    HeadExpander.toggleInfiniteJump(false)
    HeadExpander.toggleWalkSpeed(false)
end
if XRay and XRay.init then 
    XRay.init() 
end
if UI and UI.init then 
    UI.init() 
end

-- ========== INPUT HANDLER ==========
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

-- Update Loops
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
print("Alle Cheats sind STANDARDMÄSSIG AUS")
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
print("Settings:")
print("- Save/Load Settings über die Settings-Tab (MANUELL)")
print("- Keine automatische Wiederherstellung beim Start")
print("==========================================")
