--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "team",
    Category = "BasicCommands",
    Description = "Changes a set of player's team to the given team.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to respawn.",
        },
        {
            Type = "team",
            Name = "Team",
            Description = "Team to set to.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Team: Team)
        for _, Player in Players do
            Player.Team = Team
        end
    end,
}