--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "untrack",
    Category = "BasicCommands",
    Description = "Untracks a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to untrack.",
        },
    },
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Destroy the trackers.
        for _, Player in Players do
            if Api.CommandData.PlayerTrackers[Player] then
                Api.CommandData.PlayerTrackers[Player]:Destroy()
            end
        end
    end,
}