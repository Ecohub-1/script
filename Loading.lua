local placeScripts = {
    [751310835] = "DrillGame.lua",
}

local placeId = game.PlaceId
local scriptName = placeScripts[placeId]

if scriptName then
    local url = ("https://raw.githubusercontent.com/Ecohub-1/Ecohub-1/refs/heads/main/%s/%s"):format(scriptName)
    pcall(function()
        loadstring(game:HttpGet(url))()
    end)
end
