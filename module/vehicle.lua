local Vehicle = {}

function Vehicle:Toggle(v)
    if not workspace:FindFirstChild("Vehicles") then return end

    for _, car in pairs(workspace.Vehicles:GetChildren()) do
        if v then
            if not car:FindFirstChild("Highlight") then
                Instance.new("Highlight", car)
            end
        else
            for _, obj in pairs(car:GetChildren()) do
                if obj:IsA("Highlight") then
                    obj:Destroy()
                end
            end
        end
    end
end

return Vehicle
