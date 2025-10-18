local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
WindUI:SetTheme("Dark")


local Window = WindUI:CreateWindow({
    Title = "Eco Hub",
    Icon = "app-window",
    Author = "by muilx2",
})

local Tabs = {
    Main = Window:Tab({ Title = "ออโต้ฟาม", Icon = "lucide:house" }),
    MVP = Window:Tab({ Title = "ฟังต่อสู้", Icon = "lucide:gamepad" }),
    PVP = Window:Tab({ Title = "ฟังชั่นอื่น", Icon = "lucide:gamepad-2" }),
}

Window:Tag({
    Title = "Make by muilx2",
    Color = Color3.fromHex("#9400D3"),
    Radius = 13,
})


-- ⚙️ ตั้งค่าพื้นฐาน
local player = game.Players.LocalPlayer
local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

-- 🌐 ค่าพารามิเตอร์เริ่มต้น
getgenv().AutoPrompt = false
getgenv().PromptRadius = 35 -- ระยะหา prompt
getgenv().PromptDelay = 5   -- หน่วงเวลาเริ่มต้นขั้นต่ำ 3 วินาที

-- 🔄 ฟังก์ชันยิง ProximityPrompt ใกล้ตัว
fireNearbyProximityPrompts = function(radius)
    local root = getRoot()
    if not root then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if not getgenv().AutoPrompt then break end
        if obj:IsA("ProximityPrompt") and obj.Enabled and obj.Parent and obj.Parent:IsA("BasePart") then
            local part = obj.Parent
            if (part.Position - root.Position).Magnitude <= radius then
                pcall(fireproximityprompt, obj)
                task.wait(getgenv().PromptDelay)
            end
        end
    end
end

Tabs.Main:Section({  Title = "ฟามร้านซ่อม", })

Tabs.Main:Toggle({
    Title = "ออโต้ฟามซ่อม",
    Default = false,
    Callback = function(state)
        getgenv().AutoPrompt = state
        if state then
            if getgenv().AutoPromptThread then return end
            getgenv().AutoPromptThread = task.spawn(function()
                while getgenv().AutoPrompt do
                    fireNearbyProximityPrompts(getgenv().PromptRadius)
                    task.wait(0.2)
                end
                getgenv().AutoPromptThread = nil
            end)
        else
            getgenv().AutoPrompt = false
        end
    end
})

Tabs.Main:Input({
    Title = "ปรับDelay",
    Placeholder = "5-10",
    Default = tostring(getgenv().PromptDelay),
    Numeric = true, 
    Callback = function(val)
        local num = tonumber(val)
        if not num then return end 
        if num < 5 then num = 5 end
        if num > 10 then num = 10 end
        getgenv().PromptDelay = num
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local depth = 20
local noclip = true
local undergroundPlatform = nil

local function createPlatform(position)
	if undergroundPlatform then
		undergroundPlatform:Destroy()
	end
	local platform = Instance.new("Part")
	platform.Size = Vector3.new(12, 1, 12)
	platform.Anchored = true
	platform.Color = Color3.fromRGB(70, 70, 70)
	platform.Material = Enum.Material.SmoothPlastic
	platform.CFrame = CFrame.new(position.X, position.Y - 3, position.Z)
	platform.Parent = workspace
	undergroundPlatform = platform
end

RunService.Stepped:Connect(function()
	if noclip and character then
		for _, v in ipairs(character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
				v.Velocity = Vector3.zero
				v.AssemblyLinearVelocity = Vector3.zero
			end
		end
	end
end)

local function warpDown()
	root.CFrame = root.CFrame * CFrame.new(0, -depth, 0)
	createPlatform(root.Position)
end

local function warpUp()
	root.CFrame = root.CFrame * CFrame.new(0, depth, 0)
	if undergroundPlatform then
		undergroundPlatform:Destroy()
	end
end

Tabs.Main:Button({
	Title = "มุดดิน",
	Description = "มุดลงใต้ดิน",
	Callback = warpDown
})

Tabs.Main:Button({
	Title = "วาปขึ้น",
	Description = "กลับขึ้นพื้น",
	Callback = warpUp
})

Tabs.Main:Section({  Title = "ฟามก่อสร้าง",  })

getgenv().AutoE = false
getgenv().AutoEThread = nil
getgenv().AutoEDelay = 3.75

Tabs.Main:Toggle({
    Title = "ฟามก่อสร้าง",
    Default = false,
    Callback = function(state)
        getgenv().AutoE = state

        if state and not getgenv().AutoEThread then
            getgenv().AutoEThread = task.spawn(function()
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local humanoid = character:WaitForChild("Humanoid")
                local root = character:WaitForChild("HumanoidRootPart")

                -- 👇 ชื่อโฟลเดอร์ใน workspace
                local folder = workspace["\224\184\135\224\184\178\224\184\153\224\184\129\224\185\136\224\184\173\224\184\170\224\184\163\224\185\137\224\184\178\224\184\135"]

                -- 📜 ฟังก์ชัน: หาเฉพาะ Hold E ที่ Enabled เท่านั้น
                local function getEnabledPrompts()
                    local list = {}
                    for _, obj in ipairs(folder:GetDescendants()) do
                        local prompt = obj:FindFirstChild("Hold E")
                        if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            table.insert(list, prompt)
                        end
                    end
                    return list
                end

                while getgenv().AutoE do
                    -- 🔍 เอาเฉพาะที่ Enabled
                    local enabledPrompts = getEnabledPrompts()

                    -- 📏 เรียงจากใกล้ → ไกล
                    table.sort(enabledPrompts, function(a, b)
                        local pa = a.Parent and a.Parent.Position
                        local pb = b.Parent and b.Parent.Position
                        if pa and pb then
                            return (pa - root.Position).Magnitude < (pb - root.Position).Magnitude
                        end
                        return false
                    end)

                    -- 🚶‍♂️ เดินเก็บเฉพาะ Enabled
                    for _, prompt in ipairs(enabledPrompts) do
                        if not getgenv().AutoE then break end
                        if prompt and prompt.Enabled and prompt.Parent and prompt.Parent:IsA("BasePart") then
                            local part = prompt.Parent

                            humanoid:MoveTo(part.Position)
                            humanoid.MoveToFinished:Wait(4)
                            task.wait(0.1)

                            if (root.Position - part.Position).Magnitude <= 12 and prompt.Enabled then
                                pcall(fireproximityprompt, prompt)
                                task.wait(0.5)
                            end

                            task.wait(getgenv().AutoEDelay)
                        end
                    end

                    task.wait(1) -- 🔁 วนใหม่ (เผื่อของเกิดใหม่)
                end

                getgenv().AutoEThread = nil
            end)
        end
    end
})

Tabs.PVP:Section({  Title = "ฟังชั่นอื่น", })

getgenv().Drop = false

Tabs.PVP:Toggle({
    Title = "ออโต้ดรอปเงิน",
    Desc = "",
    Default = false,
    Callback = function(Value)
        getgenv().Drop = Value
        task.spawn(function()
            while getgenv().Drop do
                local TextChatService = game:GetService("TextChatService")
                local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                if channel then
                    channel:SendAsync("/pay")
                end
                task.wait(1.53)
            end
        end)
    end
})


Tabs.PVP:Button({
    Title = "ปรับภาพต่ำ",
    Description = "",
    Callback = function()
        setfpscap(940)
            
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)

        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("MeshPart") or v:IsA("Part") or v:IsA("UnionOperation") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
                v.CastShadow = false
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                v.Enabled = false
            end
        end
    end
})


Tabs.MVP:Section({  Title = "ต่อสู้ทั้งหมด", })

_G.HitboxEnabled = false
_G.HitboxSize = 20
_G.HitboxColor = Color3.fromRGB(255, 0, 0)

local Players = game:GetService("Players")

local function applyHitbox(character)
	if character and character:FindFirstChild("HumanoidRootPart") then
		local hrp = character.HumanoidRootPart
		hrp.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
		hrp.Transparency = 0.7
		hrp.Color = _G.HitboxColor
		hrp.Material = Enum.Material.Neon
		hrp.CanCollide = false
	end
end

local function resetHitbox(character)
	if character and character:FindFirstChild("HumanoidRootPart") then
		local hrp = character.HumanoidRootPart
		hrp.Size = Vector3.new(2, 2, 1)
		hrp.Transparency = 0
		hrp.Color = Color3.fromRGB(163, 162, 165)
		hrp.Material = Enum.Material.Plastic
		hrp.CanCollide = true
	end
end

local function updateAllHitboxes()
	if _G.HitboxEnabled then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= Players.LocalPlayer and player.Character then
				pcall(applyHitbox, player.Character)
			end
		end
	end
end

local function monitorCharacter(character)
	if not character then return end
	if _G.HitboxEnabled then
		pcall(applyHitbox, character)
	else
		pcall(resetHitbox, character)
	end
	character.ChildAdded:Connect(function(child)
		if child.Name == "HumanoidRootPart" then
			if _G.HitboxEnabled then
				pcall(applyHitbox, character)
			else
				pcall(resetHitbox, character)
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
	Title = "ปรับ Hitbox",
	Default = false,
	Callback = function(state)
		_G.HitboxEnabled = state
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= Players.LocalPlayer and player.Character then
				if state then
					pcall(applyHitbox, player.Character)
				else
					pcall(resetHitbox, player.Character)
				end
			end
		end
	end
})

Tabs.MVP:Input({
	Title = "ขนาด Hitbox",
	Default = tostring(_G.HitboxSize),
	Numeric = true,
	Callback = function(value)
		local size = tonumber(value)
		if size then
			_G.HitboxSize = size
			updateAllHitboxes()
		end
	end
})

Tabs.MVP:Colorpicker({
	Title = "เลือกสี Hitbox (Real-Time)",
	Default = _G.HitboxColor,
	Callback = function(color)
		_G.HitboxColor = color
		updateAllHitboxes()
	end
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().SpeedEnabled = false
getgenv().SpeedValue = 32

local MAX_SPEED = 1000

local function clampSpeed(speed)
    if speed < 0 then
        return 0
    elseif speed > MAX_SPEED then
        return MAX_SPEED
    else
        return speed
    end
end

-- ฟังก์ชัน Notify ของ WindUI
local function notify(msg)
    WindUI:Notify({
        Title = "Speed Info",
        Text = msg,
        Duration = 3
    })
end

-- loop ปรับ WalkSpeed เฉพาะตอนเปิด
local function speedLoop()
    task.spawn(function()
        while true do
            task.wait(0.1)
            if getgenv().SpeedEnabled then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = clampSpeed(getgenv().SpeedValue)
                end
            end
        end
    end)
end

Tabs.MVP:Toggle({
    Title = "วิ่งเร็ว",
    Default = false,
    Callback = function(state)
        getgenv().SpeedEnabled = state
        if state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = clampSpeed(getgenv().SpeedValue)
        end
    end
})

Tabs.MVP:Input({
    Title = "ปรับค่า Speed",
    Placeholder = "ใส่ค่า WalkSpeed",
    Default = tostring(getgenv().SpeedValue),
    Callback = function(value)
        local num = tonumber(value)
        if not num or num <= 0 then
            notify("ใส่ตัวเลขมากกว่า 0")
            return
        elseif num > MAX_SPEED then
            notify("ห้ามใส่เกิน 1000!")
            return
        end

        getgenv().SpeedValue = num
        if getgenv().SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = num
        end
    end
})

Tabs.MVP:Button({
    Title = "Reset Speed",
    Callback = function()
        getgenv().SpeedValue = 32
        if getgenv().SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 32
        end
        notify("รีเซ็ต WalkSpeed เรียบร้อย")
    end
})

-- เริ่ม loop
speedLoop()

-- ปรับตัวละครใหม่เมื่อ respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    if getgenv().SpeedEnabled then
        char:WaitForChild("Humanoid").WalkSpeed = clampSpeed(getgenv().SpeedValue)
    end
end)

Tabs.MVP:Section({  Title = "Esp", })

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {
    MaxDistance = 1000,
    Rainbow = false,
    EnemyOnly = false,
    ShowBox = false,
    ShowName = false,
    ShowHealth = false,
    ShowDistance = false,
    ShowTracer = false,
    Colors = {
        Enemy = Color3.fromRGB(255, 80, 80),
        Ally = Color3.fromRGB(80, 255, 80),
        Name = Color3.fromRGB(255, 255, 255),
        Health = Color3.fromRGB(80, 255, 80)
    },
    Objects = {}
}

local function rainbow()
    local hue = (tick() % 5) / 5
    return Color3.fromHSV(hue, 1, 1)
end

local function CreateESP(player)
    if ESP.Objects[player] then return end
    local drawings = {
        Box = { TL = Drawing.new("Line"), TR = Drawing.new("Line"), BL = Drawing.new("Line"), BR = Drawing.new("Line") },
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthBarOutline = Drawing.new("Line"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    for _, v in pairs(drawings) do
        if typeof(v) == "table" then
            for _, l in pairs(v) do
                l.Visible = false
                l.Thickness = 2
                l.ZIndex = 2
            end
        else
            v.Visible = false
            v.Center = true
            v.Outline = true
            v.Size = 14
            v.ZIndex = 2
        end
    end
    ESP.Objects[player] = drawings
end

local function ClearESP(player)
    local esp = ESP.Objects[player]
    if not esp then return end
    for _, v in pairs(esp) do
        if typeof(v) == "table" then
            for _, l in pairs(v) do l:Remove() end
        else
            v:Remove()
        end
    end
    ESP.Objects[player] = nil
end
Players.PlayerRemoving:Connect(ClearESP)

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local esp = ESP.Objects[player]
        if not esp then
            CreateESP(player)
            esp = ESP.Objects[player]
        end

        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if root and humanoid and humanoid.Health > 0 then
            if ESP.EnemyOnly and player.Team == LocalPlayer.Team then
                for _, v in pairs(esp) do
                    if typeof(v) == "table" then for _, l in pairs(v) do l.Visible = false end
                    else v.Visible = false end
                end
                continue
            end

            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                and (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 9999

            if onScreen and dist < ESP.MaxDistance then
                local alpha = math.clamp(1 - (dist / ESP.MaxDistance), 0.3, 1)
                local color = ESP.Rainbow and rainbow() or ((player.Team == LocalPlayer.Team) and ESP.Colors.Ally or ESP.Colors.Enemy)
                local boxHeight = math.clamp(2500 / dist, 35, 250)
                local boxWidth = boxHeight / 1.6
                local x, y = pos.X, pos.Y

                if ESP.ShowBox then
                    local TL, TR, BL, BR = esp.Box.TL, esp.Box.TR, esp.Box.BL, esp.Box.BR
                    TL.From = Vector2.new(x - boxWidth / 2, y - boxHeight / 2)
                    TL.To = Vector2.new(x + boxWidth / 2, y - boxHeight / 2)
                    TR.From = TL.To
                    TR.To = Vector2.new(x + boxWidth / 2, y + boxHeight / 2)
                    BR.From = TR.To
                    BR.To = Vector2.new(x - boxWidth / 2, y + boxHeight / 2)
                    BL.From = BR.To
                    BL.To = TL.From
                    for _, l in pairs(esp.Box) do
                        l.Visible = true
                        l.Color = color
                        l.Transparency = alpha
                    end
                else
                    for _, l in pairs(esp.Box) do l.Visible = false end
                end

                if ESP.ShowName then
                    esp.Name.Text = player.DisplayName
                    esp.Name.Position = Vector2.new(x, y - boxHeight / 2 - 15)
                    esp.Name.Color = ESP.Colors.Name
                    esp.Name.Visible = true
                    esp.Name.Transparency = alpha
                else
                    esp.Name.Visible = false
                end

                if ESP.ShowHealth then
                    local hpPercent = humanoid.Health / humanoid.MaxHealth
                    esp.Health.Text = math.floor(humanoid.Health) .. " HP"
                    esp.Health.Position = Vector2.new(x, y + boxHeight / 2 + 10)
                    esp.Health.Color = ESP.Colors.Health
                    esp.Health.Visible = true
                    esp.Health.Transparency = alpha
                    esp.HealthBarOutline.From = Vector2.new(x - boxWidth / 2 - 6, y - boxHeight / 2)
                    esp.HealthBarOutline.To = Vector2.new(x - boxWidth / 2 - 6, y + boxHeight / 2)
                    esp.HealthBar.From = Vector2.new(x - boxWidth / 2 - 6, y + boxHeight / 2)
                    esp.HealthBar.To = Vector2.new(x - boxWidth / 2 - 6, y + boxHeight / 2 - boxHeight * hpPercent)
                    esp.HealthBar.Color = ESP.Colors.Health
                    esp.HealthBar.Visible = true
                    esp.HealthBarOutline.Visible = true
                else
                    esp.Health.Visible = false
                    esp.HealthBar.Visible = false
                    esp.HealthBarOutline.Visible = false
                end

                if ESP.ShowDistance then
                    esp.Distance.Text = string.format("%.1f m", dist)
                    esp.Distance.Position = Vector2.new(x, y + boxHeight / 2 + 25)
                    esp.Distance.Color = Color3.fromRGB(150, 150, 255)
                    esp.Distance.Visible = true
                    esp.Distance.Transparency = alpha
                else
                    esp.Distance.Visible = false
                end

                if ESP.ShowTracer then
                    esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(x, y)
                    esp.Tracer.Color = color
                    esp.Tracer.Visible = true
                    esp.Tracer.Transparency = alpha
                else
                    esp.Tracer.Visible = false
                end
            else
                for _, v in pairs(esp) do
                    if typeof(v) == "table" then for _, l in pairs(v) do l.Visible = false end
                    else v.Visible = false end
                end
            end
        else
            for _, v in pairs(esp) do
                if typeof(v) == "table" then for _, l in pairs(v) do l.Visible = false end
                else v.Visible = false end
            end
        end
    end
end)

Tabs.MVP:Section({ Title = "ESP Settings" })
Tabs.MVP:Input({
    Title = "ระยะมอง ESP",
    Placeholder = "1000",
    Default = tostring(ESP.MaxDistance),
    Callback = function(txt)
        local n = tonumber(txt)
        if n then ESP.MaxDistance = math.clamp(n, 100, 10000) end
    end
})
Tabs.MVP:Toggle({ Title = "สีรุ้ง Rainbow", Default = false, Callback = function(v) ESP.Rainbow = v end })
Tabs.MVP:Toggle({ Title = "แสดงเฉพาะศัตรู", Default = false, Callback = function(v) ESP.EnemyOnly = v end })
Tabs.MVP:Toggle({ Title = "แสดงกล่อง", Default = false, Callback = function(v) ESP.ShowBox = v end })
Tabs.MVP:Toggle({ Title = "แสดงชื่อ", Default = false, Callback = function(v) ESP.ShowName = v end })
Tabs.MVP:Toggle({ Title = "แสดง HP", Default = false, Callback = function(v) ESP.ShowHealth = v end })
Tabs.MVP:Toggle({ Title = "แสดงระยะ", Default = false, Callback = function(v) ESP.ShowDistance = v end })
Tabs.MVP:Toggle({ Title = "แสดงเส้น", Default = false, Callback = function(v) ESP.ShowTracer = v end })

Tabs.MVP:Section({ Title = "ปรับสี" })
Tabs.MVP:Colorpicker({ Title = "สีศัตรู", Default = ESP.Colors.Enemy, Callback = function(c) ESP.Colors.Enemy = c end })
Tabs.MVP:Colorpicker({ Title = "สีเพื่อน", Default = ESP.Colors.Ally, Callback = function(c) ESP.Colors.Ally = c end })
Tabs.MVP:Colorpicker({ Title = "สีชื่อ", Default = ESP.Colors.Name, Callback = function(c) ESP.Colors.Name = c end })
Tabs.MVP:Colorpicker({ Title = "สี HP", Default = ESP.Colors.Health, Callback = function(c) ESP.Colors.Health = c end })