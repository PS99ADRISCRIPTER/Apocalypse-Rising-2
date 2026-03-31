local Aim = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local mouse = LocalPlayer:GetMouse()

local enabled = false
local conn

local function getClosest()
    local closest, dist = nil, 150

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, vis = workspace.CurrentCamera:WorldToScreenPoint(p.Character.Head.Position)
            if vis then
                local d = (Vector2.new(pos.X,pos.Y)-Vector2.new(mouse.X,mouse.Y)).Magnitude
                if d < dist then
                    dist = d
                    closest = p.Character.Head
                end
            end
        end
    end

    return closest
end

function Aim:Toggle(v)
    enabled = v

    if v then
        conn = RunService.RenderStepped:Connect(function()
            local t = getClosest()
            if t then
                local pos = workspace.CurrentCamera:WorldToScreenPoint(t.Position)
                mousemoverel((pos.X-mouse.X)*0.2,(pos.Y-mouse.Y)*0.2)
            end
        end)
    else
        if conn then conn:Disconnect() end
    end
end

return Aim
