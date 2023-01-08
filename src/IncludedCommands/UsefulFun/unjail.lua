--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unjail",
    Category = "UsefulFunCommands",
    Description = "Unjails a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unjail.",
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        Api.CommandData.PlayerJails = {}
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Destroy the jails.
        local PlayerJails = Api.CommandData.PlayerJails
        for _, Player in Players do
            if PlayerJails[Player] then
                PlayerJails[Player]:Destroy()
            end
        end
    end,
}