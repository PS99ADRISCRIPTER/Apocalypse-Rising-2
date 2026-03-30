local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local UI = {}

function UI:Create(Aim, ESP)

    local Window = Rayfield:CreateWindow({
        Name = "My Script",
        LoadingTitle = "Loading...",
        LoadingSubtitle = "by you"
    })

    local tab = Window:CreateTab("Main")

    tab:CreateToggle({
        Name = "Aim Assist",
        CurrentValue = false,
        Callback = function(v)
            Aim:Toggle(v)
        end
    })

    tab:CreateToggle({
        Name = "ESP",
        CurrentValue = false,
        Callback = function(v)
            ESP:Toggle(v)
        end
    })

end

return UI
