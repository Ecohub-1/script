local GameId = game.PlaceId

local GameList = {
    [751310835] = "DrillGame.lua"
}

local ScriptPath = GameList[GameId]
if ScriptPath then
    loadstring(game:HttpGet(("https://raw.githubusercontent.com/Ecohub-1/Ecohub-1/refs/heads/main/"%s"):format(ScriptPath)))()
end
