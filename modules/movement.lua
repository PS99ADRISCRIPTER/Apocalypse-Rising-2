local Movement = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local jump = false

function Movement:Speed(v)
    if LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then
            h.WalkSpeed = v and 30 or 16
        end
    end
end

function Movement:Jump(v)
    jump = v
end

UIS.JumpRequest:Connect(function()
    if jump and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState("Jumping") end
    end
end)

return Movement
