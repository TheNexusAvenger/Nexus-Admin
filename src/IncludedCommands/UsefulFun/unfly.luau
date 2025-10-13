--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

local FlyState = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("FlyState"))

return {
    Keyword = "unfly",
    Category = "UsefulFunCommands",
    Description = "Removes flight from a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unfly.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            FlyState.RemoveFromPlayer(Player)
        end
    end,
}