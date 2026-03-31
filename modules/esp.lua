-- modules/esp.lua
local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local playerEspEnabled = false
local vehicleEspEnabled = false
local playerHighlights = {}
local playerGuis = {}
local vehicleHighlights = {}
local vehicleGuis = {}
local vehicleEspConnection = nil

local PLAYER_ESP_COLOR = Color3.fromRGB(255, 255, 255)
local PLAYER_FILL_TRANSPARENCY = 0.5
local SHOW_PLAYER_NAMES = true
local SHOW_PLAYER_DISTANCE = true
local SHOW_VEHICLE_DISTANCE = true
local VEHICLE_NAME_COLOR = Color3.fromRGB(0, 120, 255)
local MAX_VEHICLE_DISTANCE = 500
local STUD_TO_M = 0.28

local function getPlayerName(player)
    if player:FindFirstChild("leaderstats") then
        local leaderstats = player.leaderstats
        if leaderstats:FindFirstChild("Name") then
            return leaderstats.Name.Value
        elseif leaderstats:FindFirstChild("Username") then
            return leaderstats.Username.Value
        elseif leaderstats:FindFirstChild("PlayerName") then
            return leaderstats.PlayerName.Value
        end
    end
    
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.DisplayName ~= "" then
            return humanoid.DisplayName
        end
    end
    
    return player.Name
end

local function addPlayerHighlight(char)
    if not char or not char:IsDescendantOf(workspace) then return nil end
    
    if char:FindFirstChild("PlayerHighlight") then
        char.PlayerHighlight:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillColor = PLAYER_ESP_COLOR
    highlight.OutlineColor = PLAYER_ESP_COLOR
    highlight.FillTransparency = PLAYER_FILL_TRANSPARENCY
    highlight.OutlineTransparency = 0
    highlight.Parent = char
    
    return highlight
end

local function addVehicleHighlight(vehicle)
    if not vehicle or not vehicle:IsDescendantOf(workspace) then return nil end
    
    if vehicle:FindFirstChild("VehicleHighlight") then
        vehicle.VehicleHighlight:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "VehicleHighlight"
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.Parent = vehicle
    
    return highlight
end

local function removeHighlight(object)
    if object and object:FindFirstChild("PlayerHighlight") then
        object.PlayerHighlight:Destroy()
    end
    if object and object:FindFirstChild("VehicleHighlight") then
        object.VehicleHighlight:Destroy()
    end
end

local function createPlayerLabel(char, player)
    if not char or not char:FindFirstChild("Head") then return nil end
    
    local head = char.Head
    
    if head:FindFirstChild("PlayerLabel") then
        head.PlayerLabel:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerLabel"
    billboard.Size = UDim2.new(0, 200, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = head
    billboard.Parent = head

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = billboard

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = container

    local nameText = Instance.new("TextLabel")
    nameText.Name = "NameText"
    nameText.Size = UDim2.new(0, 0, 1, 0)
    nameText.AutomaticSize = Enum.AutomaticSize.X
    nameText.BackgroundTransparency = 1
    nameText.TextColor3 = Color3.fromRGB(255, 255, 0)
    nameText.TextStrokeTransparency = 0.3
    nameText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameText.TextScaled = false
    nameText.TextSize = 14
    nameText.Font = Enum.Font.GothamBold
    nameText.Text = getPlayerName(player)
    nameText.Visible = SHOW_PLAYER_NAMES
    nameText.LayoutOrder = 1
    nameText.Parent = container

    local distanceText = Instance.new("TextLabel")
    distanceText.Name = "DistanceText"
    distanceText.Size = UDim2.new(0, 0, 1, 0)
    distanceText.AutomaticSize = Enum.AutomaticSize.X
    distanceText.BackgroundTransparency = 1
    distanceText.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceText.TextStrokeTransparency = 0.5
    distanceText.TextScaled = false
    distanceText.TextSize = 16
    distanceText.Font = Enum.Font.GothamSemibold
    distanceText.Text = ""
    distanceText.Visible = SHOW_PLAYER_DISTANCE
    distanceText.LayoutOrder = 2
    distanceText.Parent = container

    return billboard
end

local function createVehicleLabel(vehicle)
    if not vehicle then return nil end
    
    local primaryPart = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then return nil end
    
    if primaryPart:FindFirstChild("VehicleLabel") then
        primaryPart.VehicleLabel:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VehicleLabel"
    billboard.Size = UDim2.new(0, 200, 0, 25)
    billboard.StudsOffset = Vector3.new(0, primaryPart.Size.Y + 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = primaryPart
    billboard.Parent = primaryPart

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = billboard

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = container

    local nameText = Instance.new("TextLabel")
    nameText.Name = "NameText"
    nameText.Size = UDim2.new(0, 0, 1, 0)
    nameText.AutomaticSize = Enum.AutomaticSize.X
    nameText.BackgroundTransparency = 1
    nameText.TextColor3 = VEHICLE_NAME_COLOR
    nameText.TextStrokeTransparency = 0.3
    nameText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameText.TextScaled = false
    nameText.TextSize = 14
    nameText.Font = Enum.Font.GothamBold
    nameText.Text = vehicle.Name
    nameText.Visible = true
    nameText.LayoutOrder = 1
    nameText.Parent = container

    local distanceText = Instance.new("TextLabel")
    distanceText.Name = "DistanceText"
    distanceText.Size = UDim2.new(0, 0, 1, 0)
    distanceText.AutomaticSize = Enum.AutomaticSize.X
    distanceText.BackgroundTransparency = 1
    distanceText.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceText.TextStrokeTransparency = 0.5
    distanceText.TextScaled = false
    distanceText.TextSize = 16
    distanceText.Font = Enum.Font.GothamSemibold
    distanceText.Text = ""
    distanceText.Visible = SHOW_VEHICLE_DISTANCE
    distanceText.LayoutOrder = 2
    distanceText.Parent = container

    return billboard
end

local function removeLabel(object)
    if object and object:FindFirstChild("Head") then
        local head = object.Head
        if head and head:FindFirstChild("PlayerLabel") then
            head.PlayerLabel:Destroy()
        end
    end
    
    if object then
        local primaryPart = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
        if primaryPart and primaryPart:FindFirstChild("VehicleLabel") then
            primaryPart.VehicleLabel:Destroy()
        end
    end
end

local lastPlayerUpdate = 0
local PLAYER_UPDATE_INTERVAL = 0.2

function ESP.updatePlayerVisuals()
    if _G.UltimateCheat and _G.UltimateCheat.PAUSED then return end
    if not playerEspEnabled then return end
    
    local currentTime = tick()
    if currentTime - lastPlayerUpdate < PLAYER_UPDATE_INTERVAL then return end
    lastPlayerUpdate = currentTime
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    
                    local highlight = char:FindFirstChild("PlayerHighlight")
                    if not highlight then
                        highlight = addPlayerHighlight(char)
                        playerHighlights[player] = highlight
                    else
                        highlight.FillColor = PLAYER_ESP_COLOR
                        highlight.OutlineColor = PLAYER_ESP_COLOR
                        highlight.FillTransparency = PLAYER_FILL_TRANSPARENCY
                    end
                    
                    local label = char:FindFirstChild("Head") and char.Head:FindFirstChild("PlayerLabel")
                    if not label then
                        label = createPlayerLabel(char, player)
                        playerGuis[player] = label
                    else
                        local container = label:FindFirstChild("Container")
                        if container then
                            local nameText = container:FindFirstChild("NameText")
                            local distanceText = container:FindFirstChild("DistanceText")
                            
                            if nameText then
                                nameText.Visible = SHOW_PLAYER_NAMES
                            end
                            if distanceText then
                                distanceText.Visible = SHOW_PLAYER_DISTANCE
                                if SHOW_PLAYER_DISTANCE and myRoot then
                                    local distStuds = (myRoot.Position - root.Position).Magnitude
                                    local distMeters = distStuds * STUD_TO_M
                                    distanceText.Text = string.format("%.1f m", distMeters)
                                else
                                    distanceText.Text = ""
                                end
                            end
                        end
                    end
                else
                    removeHighlight(char)
                    removeLabel(char)
                end
            else
                if playerHighlights[player] then
                    removeHighlight(playerHighlights[player].Parent)
                    playerHighlights[player] = nil
                end
                if playerGuis[player] then
                    removeLabel(playerGuis[player].Parent)
                    playerGuis[player] = nil
                end
            end
        end
    end
end

local lastVehicleUpdate = 0
local VEHICLE_UPDATE_INTERVAL = 0.3

function ESP.updateVehicleESP()
    if _G.UltimateCheat and _G.UltimateCheat.PAUSED then return end
    if not vehicleEspEnabled then return end
    
    local currentTime = tick()
    if currentTime - lastVehicleUpdate < VEHICLE_UPDATE_INTERVAL then return end
    lastVehicleUpdate = currentTime
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    if not workspace:FindFirstChild("Vehicles") then
        return
    end
    
    for _, vehicle in pairs(workspace.Vehicles:GetChildren()) do
        if vehicle:IsA("Model") then
            local primaryPart = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
            if primaryPart then
                local distance = (myRoot.Position - primaryPart.Position).Magnitude
                
                if distance <= MAX_VEHICLE_DISTANCE then
                    local highlight = vehicle:FindFirstChild("VehicleHighlight")
                    if not highlight then
                        highlight = addVehicleHighlight(vehicle)
                        vehicleHighlights[vehicle.Name] = highlight
                    end
                    
                    local label = (primaryPart:FindFirstChild("VehicleLabel") or vehicle:FindFirstChild("VehicleLabel"))
                    if not label then
                        label = createVehicleLabel(vehicle)
                        vehicleGuis[vehicle.Name] = label
                    else
                        local container = label:FindFirstChild("Container")
                        if container then
                            local distanceText = container:FindFirstChild("DistanceText")
                            if distanceText then
                                distanceText.Visible = SHOW_VEHICLE_DISTANCE
                                if SHOW_VEHICLE_DISTANCE then
                                    local distMeters = distance * STUD_TO_M
                                    distanceText.Text = string.format("%.1f m", distMeters)
                                else
                                    distanceText.Text = ""
                                end
                            end
                        end
                    end
                else
                    removeHighlight(vehicle)
                    removeLabel(vehicle)
                    vehicleHighlights[vehicle.Name] = nil
                    vehicleGuis[vehicle.Name] = nil
                end
            end
        end
    end
    
    for vehicleName, _ in pairs(vehicleHighlights) do
        if not workspace.Vehicles:FindFirstChild(vehicleName) then
            local vehicle = workspace.Vehicles[vehicleName]
            if vehicle then
                removeHighlight(vehicle)
                removeLabel(vehicle)
            end
            vehicleHighlights[vehicleName] = nil
            vehicleGuis[vehicleName] = nil
        end
    end
end

local function cleanupPlayerVisuals()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            removeHighlight(player.Character)
            removeLabel(player.Character)
        end
    end
    playerHighlights = {}
    playerGuis = {}
end

local function cleanupVehicleVisuals()
    if workspace:FindFirstChild("Vehicles") then
        for _, vehicle in pairs(workspace.Vehicles:GetChildren()) do
            removeHighlight(vehicle)
            removeLabel(vehicle)
        end
    end
    vehicleHighlights = {}
    vehicleGuis = {}
end

function ESP.togglePlayerESP(state)
    playerEspEnabled = state
    
    if state then
        ESP.updatePlayerVisuals()
    else
        cleanupPlayerVisuals()
    end
end

function ESP.toggleVehicleESP(state)
    vehicleEspEnabled = state
    
    if state then
        if not vehicleEspConnection then
            vehicleEspConnection = RunService.Heartbeat:Connect(ESP.updateVehicleESP)
        end
        ESP.updateVehicleESP()
    else
        if vehicleEspConnection then
            vehicleEspConnection:Disconnect()
            vehicleEspConnection = nil
        end
        cleanupVehicleVisuals()
    end
end

function ESP.isPlayerEspEnabled() return playerEspEnabled end
function ESP.isVehicleEspEnabled() return vehicleEspEnabled end

function ESP.setPlayerColor(color) PLAYER_ESP_COLOR = color end
function ESP.setPlayerFillTransparency(trans) PLAYER_FILL_TRANSPARENCY = trans end
function ESP.setShowPlayerNames(show) SHOW_PLAYER_NAMES = show end
function ESP.setShowPlayerDistance(show) SHOW_PLAYER_DISTANCE = show end
function ESP.setShowVehicleDistance(show) SHOW_VEHICLE_DISTANCE = show end
function ESP.setMaxVehicleDistance(dist) MAX_VEHICLE_DISTANCE = dist end

function ESP.init()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(char)
                task.wait(1)
                ESP.updatePlayerVisuals()
            end)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(char)
                task.wait(1)
                ESP.updatePlayerVisuals()
            end)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if playerHighlights[player] then
            removeHighlight(playerHighlights[player].Parent)
            playerHighlights[player] = nil
        end
        if playerGuis[player] then
            removeLabel(playerGuis[player].Parent)
            playerGuis[player] = nil
        end
    end)
end

return ESP
