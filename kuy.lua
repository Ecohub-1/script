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
getgenv().PromptRadius = 20 -- ระยะหา prompt
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
    Title = "Low Graphic",
    Description = "",
    Callback = function()
        setfpscap(240)
            
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

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// Settings
local ESP = {
    Enabled = false,
    MaxDistance = 1500,
    Rainbow = false,

    ShowBox = true,
    ShowName = true,
    ShowTracer = true,
    ShowHealth = true,
    ShowDistance = true,

    Colors = {
        Enemy = Color3.fromRGB(255, 25, 25),
        Ally = Color3.fromRGB(25, 255, 25),
        Health = Color3.fromRGB(0, 255, 0),
        Name = Color3.fromRGB(255, 255, 255)
    },
    Objects = {}
}

--// Rainbow color
local function rainbow()
    local hue = tick() % 5 / 5
    return Color3.fromHSV(hue, 1, 1)
end

--// Clear ESP
local function ClearESP(player)
    if ESP.Objects[player] then
        for _, v in pairs(ESP.Objects[player]) do
            if typeof(v) == "table" then
                for _, l in pairs(v) do l:Remove() end
            else
                v:Remove()
            end
        end
        ESP.Objects[player] = nil
    end
end

--// Create ESP for player
local function CreateESP(player)
    if player == LocalPlayer then return end

    local Box = {
        TL = Drawing.new("Line"),
        TR = Drawing.new("Line"),
        BL = Drawing.new("Line"),
        BR = Drawing.new("Line")
    }

    for _, line in pairs(Box) do
        line.Visible = false
        line.Thickness = 1.2
    end

    local Name = Drawing.new("Text")
    Name.Size = 14
    Name.Center = true
    Name.Visible = false

    local Health = Drawing.new("Text")
    Health.Size = 13
    Health.Center = true
    Health.Visible = false

    local Distance = Drawing.new("Text")
    Distance.Size = 13
    Distance.Center = true
    Distance.Visible = false

    local HealthBarOutline = Drawing.new("Line")
    local HealthBar = Drawing.new("Line")
    HealthBarOutline.Visible = false
    HealthBar.Visible = false
    HealthBar.Thickness = 2

    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 1
    Tracer.Visible = false

    ESP.Objects[player] = {
        Box = Box,
        Name = Name,
        Health = Health,
        Distance = Distance,
        Tracer = Tracer,
        HealthBar = HealthBar,
        HealthBarOutline = HealthBarOutline
    }
end

--// Update ESP
RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then
        for _, obj in pairs(ESP.Objects) do
            for _, v in pairs(obj) do
                if typeof(v) == "table" then
                    for _, l in pairs(v) do l.Visible = false end
                else
                    v.Visible = false
                end
            end
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local esp = ESP.Objects[player]
            if not esp then
                CreateESP(player)
                esp = ESP.Objects[player]
            end

            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if root and humanoid then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 9999
                local alpha = math.clamp(1 - (distance / ESP.MaxDistance), 0.2, 1)

                if onScreen and distance < ESP.MaxDistance then
                    local boxHeight = math.clamp(2500 / distance, 30, 250)
                    local boxWidth = boxHeight / 1.6
                    local x, y = pos.X, pos.Y
                    local isAlly = (player.Team == LocalPlayer.Team)
                    local color = ESP.Rainbow and rainbow() or (isAlly and ESP.Colors.Ally or ESP.Colors.Enemy)

                    -- Box
                    if ESP.ShowBox then
                        local tl, tr, bl, br = esp.Box.TL, esp.Box.TR, esp.Box.BL, esp.Box.BR
                        tl.From = Vector2.new(x - boxWidth/2, y - boxHeight/2)
                        tl.To   = Vector2.new(x + boxWidth/2, y - boxHeight/2)
                        tr.From = Vector2.new(x + boxWidth/2, y - boxHeight/2)
                        tr.To   = Vector2.new(x + boxWidth/2, y + boxHeight/2)
                        br.From = Vector2.new(x + boxWidth/2, y + boxHeight/2)
                        br.To   = Vector2.new(x - boxWidth/2, y + boxHeight/2)
                        bl.From = Vector2.new(x - boxWidth/2, y + boxHeight/2)
                        bl.To   = Vector2.new(x - boxWidth/2, y - boxHeight/2)

                        for _, line in pairs(esp.Box) do
                            line.Visible = true
                            line.Color = color
                            line.Transparency = alpha
                        end
                    else
                        for _, line in pairs(esp.Box) do line.Visible = false end
                    end

                    -- Name
                    esp.Name.Visible = ESP.ShowName
                    if ESP.ShowName then
                        esp.Name.Text = player.DisplayName
                        esp.Name.Position = Vector2.new(x, y - boxHeight / 2 - 15)
                        esp.Name.Color = ESP.Colors.Name
                        esp.Name.Transparency = alpha
                    end

                    -- Health Text + Bar
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    if ESP.ShowHealth then
                        esp.Health.Visible = true
                        esp.Health.Text = math.floor(humanoid.Health) .. " HP"
                        esp.Health.Position = Vector2.new(x, y + boxHeight / 2 + 10)
                        esp.Health.Color = ESP.Colors.Health
                        esp.Health.Transparency = alpha

                        esp.HealthBarOutline.Visible = true
                        esp.HealthBar.Visible = true
                        esp.HealthBarOutline.From = Vector2.new(x - boxWidth/2 - 6, y - boxHeight/2)
                        esp.HealthBarOutline.To = Vector2.new(x - boxWidth/2 - 6, y + boxHeight/2)
                        esp.HealthBar.From = Vector2.new(x - boxWidth/2 - 6, y + boxHeight/2)
                        esp.HealthBar.To = Vector2.new(x - boxWidth/2 - 6, y + boxHeight/2 - boxHeight * healthPercent)
                        esp.HealthBar.Color = ESP.Colors.Health
                    else
                        esp.Health.Visible = false
                        esp.HealthBar.Visible = false
                        esp.HealthBarOutline.Visible = false
                    end

                    -- Distance
                    esp.Distance.Visible = ESP.ShowDistance
                    if ESP.ShowDistance then
                        esp.Distance.Text = string.format("%.1f m", distance)
                        esp.Distance.Position = Vector2.new(x, y + boxHeight / 2 + 25)
                        esp.Distance.Color = Color3.fromRGB(200, 200, 255)
                        esp.Distance.Transparency = alpha
                    end

                    -- Tracer
                    esp.Tracer.Visible = ESP.ShowTracer
                    if ESP.ShowTracer then
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(x, y)
                        esp.Tracer.Color = color
                        esp.Tracer.Transparency = alpha
                    end
                else
                    ClearESP(player)
                end
            else
                ClearESP(player)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(ClearESP)

--// 💜 UI Controls (WindUI)
Tabs.MVP:Toggle({Title = "Enable ESP", Default = false, Callback = function(v) ESP.Enabled = v end})
Tabs.MVP:Toggle({Title = "Rainbow Mode", Default = false, Callback = function(v) ESP.Rainbow = v end})

Tabs.MVP:Slider({Title = "Max Distance", Min = 100, Max = 3000, Default = 1500, Callback = function(v) ESP.MaxDistance = v end})

Tabs.MVP:Label("🎨 Display Options")
Tabs.MVP:Toggle({Title = "Show Box", Default = true, Callback = function(v) ESP.ShowBox = v end})
Tabs.MVP:Toggle({Title = "Show Name", Default = true, Callback = function(v) ESP.ShowName = v end})
Tabs.MVP:Toggle({Title = "Show Health", Default = true, Callback = function(v) ESP.ShowHealth = v end})
Tabs.MVP:Toggle({Title = "Show Tracer", Default = true, Callback = function(v) ESP.ShowTracer = v end})
Tabs.MVP:Toggle({Title = "Show Distance", Default = true, Callback = function(v) ESP.ShowDistance = v end})

Tabs.MVP:Label("🎨 Colors")
Tabs.MVP:ColorPicker({Title = "Enemy Color", Default = ESP.Colors.Enemy, Callback = function(c) ESP.Colors.Enemy = c end})
Tabs.MVP:ColorPicker({Title = "Ally Color", Default = ESP.Colors.Ally, Callback = function(c) ESP.Colors.Ally = c end})
Tabs.MVP:ColorPicker({Title = "Health Color", Default = ESP.Colors.Health, Callback = function(c) ESP.Colors.Health = c end})
Tabs.MVP:ColorPicker({Title = "Name Color", Default = ESP.Colors.Name, Callback = function(c) ESP.Colors.Name = c end})
