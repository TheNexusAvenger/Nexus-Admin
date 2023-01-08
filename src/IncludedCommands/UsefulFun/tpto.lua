--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "tpto",
    Category = "UsefulFunCommands",
    Description = "Teleports a set of players to a specific location.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to teleport.",
        },
        {
            Type = "vector3",
            Name = "TargetPosition",
            Description = "Position to teleport to.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, TargetPosition: Vector3)
        local Util = IncludedCommandUtil.ForContext(CommandContext)

        --Telelport the players.
        local Radius = math.max(10, #Players)
        local TargetLocation = CFrame.new(TargetPosition)
        if TargetLocation then
            for _, Player in Players do
                Util:TeleportPlayer(Player, TargetLocation * CFrame.new(math.random(-Radius, Radius) / 10, 0, math.random(-Radius, Radius) / 10))
            end
        end
    end,
}