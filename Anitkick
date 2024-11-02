local getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, lower, gsub, match
    = getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, string.lower, string.gsub, string.match;

if getgenv().ED_AntiKick then
    return
end

local cloneref = cloneref or function(...) return ... end
local clonefunction = clonefunction or function(...) return ... end
local Players, LocalPlayer, StarterGui = cloneref(game:GetService("Players")), cloneref(game:GetService("Players").LocalPlayer), cloneref(game:GetService("StarterGui"))

local SetCore = clonefunction(StarterGui.SetCore)
local GetDebugId = clonefunction(game.GetDebugId)
local FindFirstChild = clonefunction(game.FindFirstChild)

local compareinstances = (compareinstances and function(ins1, ins2)
        if typeof(ins1) == "Instance" and typeof(ins2) == "Instance" then
            return compareinstances(ins1, ins2);
        end
    end)
or
function(ins1, ins2)
    return (typeof(ins1) == "Instance" and typeof(ins2) == "Instance") and GetDebugId(ins1) == GetDebugId(ins2);
end;

local function CanCastToSTDString(val)
    local success, err = pcall(FindFirstChild, game, val);
    return success
end

getgenv().ED_AntiKick = {
    Enabled = true,
    SendNotifications = false,
    CheckCaller = false
}

local OldNamecall;
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local self, message = ...
    local method = getnamecallmethod()
    
    if ((getgenv().ED_AntiKick.CheckCaller and not checkcaller()) or true) and compareinstances(self, LocalPlayer) and gsub(method, "^%l", string.upper) == "Kick" and ED_AntiKick.Enabled then
        if CanCastToSTDString(message) then
            return;
        end
    end

    return OldNamecall(...)
end))

local OldFunction;
OldFunction = hookfunction(LocalPlayer.Kick, function(...)
    local self, message = ...

    if ((getgenv().ED_AntiKick.CheckCaller and not checkcaller()) or true) and compareinstances(self, LocalPlayer) and ED_AntiKick.Enabled then
        if CanCastToSTDString(message) then
            return;
        end
    end
end)
