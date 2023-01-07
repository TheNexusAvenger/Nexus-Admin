--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "ph",
    Category = "BasicCommands",
    Description = "Creates a hint visible to only the players specified.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to show the message.",
        },
        {
            Type = "string",
            Name = "Message",
            Description = "Announcement text.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Message: string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        --Filter and send the message.
        for Player, FilteredMessage in Api.Filter:FilterStringForPlayers(Message, CommandContext.Executor, Players) do
            Api.Messages:DisplayHint(Player, CommandContext.Executor.Name..": "..FilteredMessage)
        end
    end,
}