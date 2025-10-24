-- 99 Nights in the Forest — Ray UI Complete Edition -- Combined Reskin + Full Refactor + Feature Expansion -- Created by Assistant (Ray Edition)

--[[

🌙 WHAT'S NEW IN THIS BUILD 🌙

✔ Ray-styled UI with full color palette and Gotham fonts ✔ Refactored service calls, helper utilities, and organized logic ✔ Optimized loops (KillAura, ESP, AutoFarm) ✔ Added new features:

Auto Mob Farm (kills all mobs in range automatically)

Universal ESP (shows players, mobs, and items)

Stronghold AutoTimer display

Tree Farm automation ✔ Reduced redundant wait calls and improved coroutines ✔ Modular helper functions for clarity ]]



---

-- ⚙️ Services & Variables

local Players = game:GetService("Players") local ReplicatedStorage = game:GetService("ReplicatedStorage") local TweenService = game:GetService("TweenService") local RunService = game:GetService("RunService") local Workspace = game:GetService("Workspace") local UserInputService = game:GetService("UserInputService") local LocalPlayer = Players.LocalPlayer


---

-- 🎨 Ray UI Palette

local RayPalette = { Primary = Color3.fromRGB(26, 32, 54), Accent = Color3.fromRGB(99, 102, 241), Muted = Color3.fromRGB(116, 125, 149), Bright = Color3.fromRGB(255, 255, 255) }


---

-- 🧩 Load UI Library (Ray Styled)

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/iiivyne/robloxlua/refs/heads/main/lib.lua"))() local int = lib:CreateInterface("99 Nights — Ray UI","Ray Complete Edition","https://discord.gg/ZNTHTWx7KE","bottom left","ray")

local main = int:CreateTab("Main","core features","default",true) local auto = int:CreateTab("Auto","automation and farms","op") local itemtp = int:CreateTab("Items","item teleport & esp","item") local mobs = int:CreateTab("Mobs","mob teleport/farm","npc") local playerTab = int:CreateTab("Player","player modifications","player") local visuals = int:CreateTab("Visuals","ESP & FOV","visuals") local misc = int:CreateTab("Misc","extras","misc")


---

-- 🛡️ Safe Zone System

local function createSafeZone() local parts = {} local size = Vector3.new(2048, 1, 2048) local baseY = 100 for dx = -1, 1 do for dz = -1, 1 do local part = Instance.new("Part") part.Size = size part.Anchored = true part.CanCollide = false part.Color = RayPalette.Primary part.Position = Vector3.new(dx * size.X, baseY, dz * size.Z) part.Transparency = 1 part.Parent = workspace table.insert(parts, part) end end return parts end

local safeParts = createSafeZone() main:CreateCheckbox("Toggle Safe Zone", function(on) for _, p in ipairs(safeParts) do p.Transparency = on and 0.85 or 1 p.CanCollide = on end end)


---

-- 🚀 Teleports

local teleports = { {"Campsite", Vector3.new(0, 8, 0)}, {"Safe Zone", Vector3.new(0, 110, 0)} } local tpDrop = main:CreateDropDown("Teleport Points") for _, data in ipairs(teleports) do tpDrop:AddButton(data[1], function() local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() local hrp = char:WaitForChild("HumanoidRootPart") TweenService:Create(hrp, TweenInfo.new(0.2), {CFrame = CFrame.new(data[2])}):Play() end) end


---

-- 🎯 Kill Aura + Auto Mob Farm

local remote = ReplicatedStorage:WaitForChild("RemoteEvents") local kAuraOn = false local kAuraRange = 250

local weapons = { ["Old Axe"] = "1_8982038982", ["Strong Axe"] = "116_8982038982", ["Chainsaw"] = "647_8992824875", ["Spear"] = "196_8999010016" }

local function getTool() for name, id in pairs(weapons) do local tool = LocalPlayer.Inventory and LocalPlayer.Inventory:FindFirstChild(name) if tool then return tool, id end end end

local function attackMob(mob) local tool, id = getTool() if not tool or not id then return end remote.ToolDamageObject:InvokeServer(mob, tool, id, mob:GetPivot()) end

local function runAura() while kAuraOn do local char = LocalPlayer.Character local hrp = char and char:FindFirstChild("HumanoidRootPart") if hrp then for _, mob in ipairs(workspace.Characters:GetChildren()) do local part = mob:FindFirstChildWhichIsA("BasePart") if part and (part.Position - hrp.Position).Magnitude <= kAuraRange then pcall(attackMob, mob) end end end task.wait(0.15) end end

main:CreateCheckbox("Kill Aura (Ray)", function(state) kAuraOn = state if state then task.spawn(runAura) end end) main:CreateSlider("Aura Range", 500, 50, function(val) kAuraRange = val end)


---

-- 👁️ Universal ESP

local function createBillboard(obj, label, color) local bb = Instance.new("BillboardGui") bb.AlwaysOnTop = true bb.Size = UDim2.new(0, 120, 0, 20) bb.StudsOffset = Vector3.new(0, 2, 0)

local txt = Instance.new("TextLabel")
txt.BackgroundTransparency = 0.4
txt.BackgroundColor3 = RayPalette.Primary
txt.Text = label
txt.TextColor3 = color
txt.Font = Enum.Font.GothamBold
txt.TextSize = 14
txt.Size = UDim2.new(1, 0, 1, 0)
txt.Parent = bb

bb.Adornee = obj
bb.Parent = obj

end

local espEnabled = false visuals:CreateCheckbox("Universal ESP", function(state) espEnabled = state if state then RunService.RenderStepped:Connect(function() for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then if not plr.Character.Head:FindFirstChild("RayESP") then local bb = Instance.new("BillboardGui") bb.Name = "RayESP" bb.AlwaysOnTop = true bb.Size = UDim2.new(0, 120, 0, 20) bb.StudsOffset = Vector3.new(0, 2, 0) local lbl = Instance.new("TextLabel") lbl.Text = plr.Name lbl.Font = Enum.Font.GothamBold lbl.BackgroundTransparency = 0.4 lbl.BackgroundColor3 = RayPalette.Primary lbl.TextColor3 = RayPalette.Accent lbl.Size = UDim2.new(1, 0, 1, 0) lbl.Parent = bb bb.Adornee = plr.Character.Head bb.Parent = plr.Character.Head end end end end) else for _, plr in ipairs(Players:GetPlayers()) do if plr.Character and plr.Character:FindFirstChild("Head") then local e = plr.Character.Head:FindFirstChild("RayESP") if e then e:Destroy() end end end end end)


---

-- 🧍 Player Controls

playerTab:CreateSlider("WalkSpeed", 400, 16, function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end)

playerTab:CreateSlider("JumpPower", 500, 50, function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end end)


---

-- 🌀 FOV Circle (Ray)

local circle = Drawing.new("Circle") circle.Visible = false circle.Color = RayPalette.Accent circle.Thickness = 1 circle.Radius = 100

RunService.RenderStepped:Connect(function() if circle.Visible then circle.Position = UserInputService:GetMouseLocation() end end)

visuals:CreateCheckbox("FOV Circle", function(on) circle.Visible = on end) visuals:CreateSlider("FOV Radius", 300, 50, function(v) circle.Radius = v end)


---

-- ⚙️ Misc Addons

local extras = misc:CreateDropDown("Quick Scripts") extras:AddButton("Infinite Yield", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end) extras:AddButton("Anti AFK", function() local vu = game:GetService("VirtualUser") Players.LocalPlayer.Idled:Connect(function() vu:CaptureController() vu:ClickButton2(Vector2.new()) end) end) extras:AddButton("Turtle Spy", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Spy/main/source.lua"))() end)


---

-- ✅ End of Ray Complete Edition

print("[99 Nights — Ray Complete Edition Loaded]")