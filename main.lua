-- main.lua
-- Anti-Double-Load
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
local ExecutorName = "Unknown"
pcall(function()
    local name = getexecutorname()
    if name and name ~= "" then ExecutorName = name end
end)

-- Rayfield laden
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Messages = {
    "Playing with " .. ExecutorName .. " 🎯",
    "Running on " .. ExecutorName .. " 👁️",
    ExecutorName .. " Edition ⚡",
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
        Enabled = false,
        FolderName = "UltimateCheatConfigs",
        FileName = "Configuration",
    },
})

-- KURZE WARTEZEIT, DAMIT RAYFIELD FERTIG IST
task.wait(0.2)

-- Tabs erstellen (mit Prüfung)
local AimTab = Window:CreateTab("Aim Assist", "target")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local PlayerTab = Window:CreateTab("Player", "user")
local SettingsTab = Window:CreateTab("Settings", "settings")

-- Prüfen ob Tabs existieren
if not AimTab or not VisualsTab or not PlayerTab or not SettingsTab then
    warn("Fehler: Tabs konnten nicht erstellt werden")
    return
end

print("Tabs erfolgreich erstellt")

-- Module laden (mit Fehlerbehandlung)
local AimAssist, ESP, HeadExpander, XRay, UI

pcall(function()
    AimAssist = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/aimassist.lua"))()
    print("AimAssist geladen")
end)

pcall(function()
    ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/esp.lua"))()
    print("ESP geladen")
end)

pcall(function()
    HeadExpander = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/headexpander.lua"))()
    print("HeadExpander geladen")
end)

pcall(function()
    XRay = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/xray.lua"))()
    print("Xray geladen")
end)

pcall(function()
    UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/modules/ui.lua"))()
    print("UI geladen")
end)

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

-- Module initialisieren (mit Fehlerbehandlung)
pcall(function() if AimAssist and AimAssist.init then AimAssist.init() AimAssist.toggle(false) end end)
pcall(function() if ESP and ESP.init then ESP.init() ESP.togglePlayerESP(false) ESP.toggleVehicleESP(false) end end)
pcall(function() if HeadExpander and HeadExpander.init then HeadExpander.init() HeadExpander.toggle(false) HeadExpander.toggleInfiniteJump(false) HeadExpander.toggleWalkSpeed(false) end end)
pcall(function() if XRay and XRay.init then XRay.init() end end)
pcall(function() if UI and UI.init then UI.init() end end)

-- Input Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        if Rayfield then Rayfield:SetVisibility(not Rayfield:IsVisible()) end
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
    if ESP and ESP.isPlayerEspEnabled() then ESP.updatePlayerVisuals() end
    if ESP and ESP.isVehicleEspEnabled() then ESP.updateVehicleESP() end
    if AimAssist then AimAssist.updateFOVCircle() end
end)

print("==========================================")
print("Ultimate Cheat Suite geladen!")
print("Executor: " .. ExecutorName)
print("Alle Cheats sind AUS")
print("==========================================")
