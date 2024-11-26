--Implementation of a command.
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "sm",
    Category = "BasicCommands",
    Description = "Creates a message visible to everyone. The displayed name is \"Nexus Admin\".",
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
            Api.Messages:DisplayMessage(Player, "Nexus Admin", Api.Filter:EscapeRichText(FilteredMessage))
        end
    end,
}