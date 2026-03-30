local XRay = {}

local active = false
local parts = {}

function XRay:Toggle()
    if not active then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                parts[v] = v.Transparency
                v.Transparency = 0.8
            end
        end
        active = true
    else
        for p,t in pairs(parts) do
            if p then p.Transparency = t end
        end
        parts = {}
        active = false
    end
end

return XRay
