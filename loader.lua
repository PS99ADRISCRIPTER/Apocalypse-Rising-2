-- loader.lua
local repo = "https://raw.githubusercontent.com/PS99ADRISCRIPTER/Apocalypse-Rising-2/main/"

local loadedModules = {}

local function requireModule(moduleName)
    if loadedModules[moduleName] then
        return loadedModules[moduleName]
    end
    
    local url = repo .. "modules/" .. moduleName .. ".lua"
    local success, result = pcall(function()
        local content = game:HttpGet(url)
        return loadstring(content)()
    end)
    
    if success then
        loadedModules[moduleName] = result
        return result
    else
        warn("Fehler beim Laden von " .. moduleName .. ": " .. tostring(result))
        return nil
    end
end

_G.UltimateCheat = {
    require = requireModule,
    loadedModules = loadedModules
}

local mainScript = game:HttpGet(repo .. "main.lua")
local mainFunction = loadstring(mainScript)
mainFunction()

print("Ultimate Cheat Suite geladen!")
