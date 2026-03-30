local base = "https://raw.githubusercontent.com/DEINNAME/Apocalypse-Rising-2/main/"

local Aim = loadstring(game:HttpGet(base.."modules/aim.lua"))()
local ESP = loadstring(game:HttpGet(base.."modules/esp.lua"))()
local Movement = loadstring(game:HttpGet(base.."modules/movement.lua"))()
local XRay = loadstring(game:HttpGet(base.."modules/xray.lua"))()

local UI = loadstring(game:HttpGet(base.."ui/window.lua"))()

UI:Create(Aim, ESP, Movement, XRay)

print("FULL SCRIPT LOADED")
