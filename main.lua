local base = "https://raw.githubusercontent.com/DEINNAME/Apocalypse-Rising-2/main/"

local Aim = loadstring(game:HttpGet(base.."modules/aim.lua"))()
local ESP = loadstring(game:HttpGet(base.."modules/esp.lua"))()

local UI = loadstring(game:HttpGet(base.."ui/window.lua"))()

-- Tabs erstellen
UI:Create(Aim, ESP)

print("Script loaded clean")
