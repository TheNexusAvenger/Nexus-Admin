--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "age",
    Category = "BasicCommands",
    Description = "Displays the age of a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to show the age of.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)

        --Show the ages.
        for _, Player in Players do
            Util:SendMessage(Player.DisplayName.." ("..Player.Name..", "..tostring(Player.UserId)..") has the age of "..tostring(Player.AccountAge).." days.")
        end
    end,
}