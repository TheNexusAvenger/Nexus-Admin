--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unvibrate",
    Category = "FunCommands",
    Description = "Unvibrates a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unvibrate.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()
    
        --Stop the vibrating.
        for _, Player in Players do
            if Api.CommandData.PlayerVibrations[Player] then
                Api.CommandData.PlayerVibrations[Player]:Destroy()
            end
        end
    end,
}