local ESP = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function ESP:Toggle(v)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if v then
                if not p.Character:FindFirstChild("Highlight") then
                    Instance.new("Highlight", p.Character)
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
