--[[
TheNexusAvenger

Replicates instances to players.
--]]

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))

local Replicator = NexusObject:Extend()
Replicator:SetClassName("Replicator")



--[[
Creates a replicator instance.
--]]
function Replicator:__new(NexusAdminRemotes)
    self:InitializeSuper()

    self.Players = game:GetService("Players")
    self.StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
end

--[[
Gives a script to a player.
--]]
function Replicator:GiveScriptToPlayer(Player,Script)
    local PlayerGui = Player:FindFirstChild("PlayerGui")
    if PlayerGui then
        local ScriptParent = Instance.new("ScreenGui")
        ScriptParent.Name = "NexusAdminScript_"..Script.Name
        ScriptParent.ResetOnSpawn = false
        Script:Clone().Parent = ScriptParent
        ScriptParent.Parent = PlayerGui
    else
        warn(Player.Name " didn't have a PlayerGui. The script was not given.")
    end
end

--[[
Gives a script to all players.
--]]
function Replicator:GiveStarterScript(Script)
    --Add the script to the starter player script.
    Script:Clone().Parent = self.StarterPlayerScripts

    --Give the player the scripts.
    for _,Player in pairs(self.Players:GetPlayers()) do
        self:GiveScriptToPlayer(Player,Script)
    end
end



return Replicator