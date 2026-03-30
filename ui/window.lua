local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local UI = {}

function UI:Init(Aim, ESP, Vehicle, Movement, XRay)

    local Window = Rayfield:CreateWindow({
        Name = "Apoc Script",
        LoadingTitle = "Loading",
        LoadingSubtitle = "..."
    })

    local main = Window:CreateTab("Main")
    local visuals = Window:CreateTab("Visuals")
    local player = Window:CreateTab("Player")

    main:CreateToggle({
        Name = "Aim",
        Callback = function(v) Aim:Toggle(v) end
    })

    visuals:CreateToggle({
        Name = "Player ESP",
        Callback = function(v) ESP:Toggle(v) end
    })

    visuals:CreateToggle({
        Name = "Vehicle ESP",
        Callback = function(v) Vehicle:Toggle(v) end
    })

    player:CreateToggle({
        Name = "Speed",
        Callback = function(v) Movement:Speed(v) end
    })

    player:CreateToggle({
        Name = "Infinite Jump",
        Callback = function(v) Movement:Jump(v) end
    })

    player:CreateButton({
        Name = "XRay",
        Callback = function() XRay:Toggle() end
    })

end

return UI
