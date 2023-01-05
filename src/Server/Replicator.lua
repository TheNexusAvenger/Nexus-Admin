--[[
TheNexusAvenger

Replicates instances to players.
--]]
--!strict

local Players = game:GetService("Players")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local Types = require(script.Parent.Parent:WaitForChild("Types"))

local Replicator = {}
Replicator.__index = Replicator



--[[
Creates a replicator instance.
--]]
function Replicator.new(): Types.Replicator
    return (setmetatable({}, Replicator) :: any) :: Types.Replicator
end

--[[
Gives a script to a player.
--]]
function Replicator:GiveScriptToPlayer(Player: Player, Script: BaseScript): ()
    local PlayerGui = Player:FindFirstChild("PlayerGui")
    if PlayerGui then
        local ScriptParent = Instance.new("ScreenGui")
        ScriptParent.Name = "NexusAdminScript_"..Script.Name
        ScriptParent.ResetOnSpawn = false
        Script:Clone().Parent = ScriptParent
        ScriptParent.Parent = PlayerGui
    else
        warn(Player.Name.." didn't have a PlayerGui. The script was not given.")
    end
end

--[[
Gives a script to all players.
--]]
function Replicator:GiveStarterScript(Script: BaseScript): ()
    --Add the script to the starter player script.
    Script:Clone().Parent = StarterPlayerScripts

    --Give the player the scripts.
    for _, Player in Players:GetPlayers() do
        self:GiveScriptToPlayer(Player, Script)
    end
end



return (Replicator :: any) :: Types.Replicator