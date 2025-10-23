

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
 WindUI:SetTheme("Dark")  

local Window = WindUI:CreateWindow({
    Title = "Eco Hub",
    Icon = "door-open", -- lucide icon. optional
    Author = "by muilx2", -- optional
})

local Tabs = {
    MVP = Window:Tab({ Title = "hitbox", Icon = "lucide:house" }),
}

Window:Tag({
    Title = "v1.6.4",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 13,
})

_G.HitboxEnabled = false
_G.HeadHitboxSize = 10
_G.HeadHitboxColor = Color3.fromRGB(255, 0, 0)

local Players = game:GetService("Players")

local function applyHeadHitbox(character)
	local head = character:FindFirstChild("Head")
	if head then
		head.Anchored = false
		head.Size = Vector3.new(_G.HeadHitboxSize, _G.HeadHitboxSize, _G.HeadHitboxSize)
		head.Transparency = 0.7
		head.Color = _G.HeadHitboxColor
		head.Material = Enum.Material.Neon
		head.CanCollide = false
	end
end

local function resetHeadHitbox(character)
	local head = character:FindFirstChild("Head")
	if head then
		head.Anchored = false
		head.Size = Vector3.new(2, 1, 1)
		head.Transparency = 0
		head.Color = Color3.fromRGB(163, 162, 165)
		head.Material = Enum.Material.Plastic
		head.CanCollide = true
	end
end

local function updateAllHeadHitboxes()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= Players.LocalPlayer and player.Character then
			if _G.HitboxEnabled then
				pcall(applyHeadHitbox, player.Character)
			else
				pcall(resetHeadHitbox, player.Character)
			end
		end
	end
end

local function monitorCharacter(character)
	if not character then return end
	task.wait(1)
	if _G.HitboxEnabled then
		pcall(applyHeadHitbox, character)
	else
		pcall(resetHeadHitbox, character)
	end
	character.ChildAdded:Connect(function(child)
		if child.Name == "Head" then
			task.wait(0.5)
			if _G.HitboxEnabled then
				pcall(applyHeadHitbox, character)
			else
				pcall(resetHeadHitbox, character)
			end
		end
	end)
end

local function setupPlayer(player)
	if player == Players.LocalPlayer then return end
	player.CharacterAdded:Connect(monitorCharacter)
	if player.Character then
		monitorCharacter(player.Character)
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end
Players.PlayerAdded:Connect(setupPlayer)

Tabs.MVP:Toggle({
	Title = "เปิด / ปิด Hitbox หัว",
	Default = false,
	Callback = function(state)
		_G.HitboxEnabled = state
		updateAllHeadHitboxes()
	end
})

Tabs.MVP:Input({
	Title = "ขนาดหัว (Hitbox)",
	Default = tostring(_G.HeadHitboxSize),
	Numeric = true,
	Callback = function(value)
		local size = tonumber(value)
		if size then
			_G.HeadHitboxSize = size
			if _G.HitboxEnabled then
				updateAllHeadHitboxes()
			end
		end
	end
})

Tabs.MVP:Colorpicker({
	Title = "เลือกสี Hitbox หัว (Real-Time)",
	Default = _G.HeadHitboxColor,
	Callback = function(color)
		_G.HeadHitboxColor = color
		if _G.HitboxEnabled then
			updateAllHeadHitboxes()
		end
	end
})


for _,v in next, getreg() do
if type(v) == "thread" then
if string.find(debug.traceback(v),"<",1,true) then
coroutine.close(v)
print("bypass")
end
end
end

for i,v in next, getallthreads() do
local s = getscriptfromthread(v)
if string.find(tostring(s), "<",1,true) then
print("bypass")
end
end
