--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "punish",
    Category = "BasicCommands",
    Description = "Punishes a set of players by removing their character.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to punish.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _,Player in Players do
            local Character = Player.Character
            if Character then
                Character:Destroy()
            end
        end
    end,
}