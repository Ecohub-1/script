

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
local RunService = game:GetService("RunService")
local Hitboxes = {}

local function createFakeHitbox(player)
    if not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    if Hitboxes[player] then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = head
    box.AlwaysOnTop = true
    box.Size = Vector3.new(_G.HeadHitboxSize, _G.HeadHitboxSize, _G.HeadHitboxSize)
    box.Transparency = 0.5
    box.Color3 = _G.HeadHitboxColor
    box.ZIndex = 10
    box.Parent = head
    Hitboxes[player] = box
end

local function removeFakeHitbox(player)
    if Hitboxes[player] then
        Hitboxes[player]:Destroy()
        Hitboxes[player] = nil
    end
end

local function updateFakeHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if _G.HitboxEnabled then
                if not Hitboxes[player] then
                    createFakeHitbox(player)
                else
                    Hitboxes[player].Size = Vector3.new(_G.HeadHitboxSize, _G.HeadHitboxSize, _G.HeadHitboxSize)
                    Hitboxes[player].Color3 = _G.HeadHitboxColor
                end
            else
                removeFakeHitbox(player)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if _G.HitboxEnabled then
            createFakeHitbox(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeFakeHitbox(player)
end)

RunService.RenderStepped:Connect(function()
    if _G.HitboxEnabled then
        updateFakeHitboxes()
    end
end)

Tabs.MVP:Toggle({
    Title = "เปิด / ปิด Hitbox หัว",
    Default = false,
    Callback = function(state)
        _G.HitboxEnabled = state
        updateFakeHitboxes()
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
            updateFakeHitboxes()
        end
    end
})

Tabs.MVP:Colorpicker({
    Title = "เลือกสี Hitbox หัว (Real-Time)",
    Default = _G.HeadHitboxColor,
    Callback = function(color)
        _G.HeadHitboxColor = color
        updateFakeHitboxes()
    end
})

for _,v in next, getreg() do
if type(v) == "thread" then
if string.find(debug.traceback(v),"<",1,true) then
coroutine.close(v)
print("ok")
end
end
end

for i,v in next, getallthreads() do
local s = getscriptfromthread(v)
if string.find(tostring(s), "<",1,true) then
print("ok")
end
end
