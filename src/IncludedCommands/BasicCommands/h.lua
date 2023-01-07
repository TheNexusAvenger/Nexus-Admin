--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "h",
    Category = "BasicCommands",
    Description = "Creates a hint visible to everyone.",
    Arguments = {
        {
            Type = "string",
            Name = "Message",
            Description = "Announcement text.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Message: string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        --Filter and send the message.
        for Player, FilteredMessage in Api.Filter:FilterStringForPlayers(Message, CommandContext.Executor, Players:GetPlayers()) do
            Api.Messages:DisplayHint(Player, CommandContext.Executor.Name..": "..FilteredMessage)
        end
    end,
}