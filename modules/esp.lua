local ESP = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false

function ESP:Toggle(v)
    enabled = v
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if v then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight")
                    h.Parent = p.Character
                end
            else
                for _, obj in pairs(p.Character:GetChildren()) do
                    if obj:IsA("Highlight") then
                        obj:Destroy()
                    end
                end
            end
        end
    end
end

return ESP
