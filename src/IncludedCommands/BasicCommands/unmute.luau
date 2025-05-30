--Implementation of a command.
--!strict

local TextChatService = game:GetService("TextChatService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unmute",
    Category = "BasicCommands",
    Description = "Unmutes a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unmute.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Mute the players.
        local TextChannels = TextChatService:FindFirstChild("TextChannels")
        local GeneralChat = TextChannels and TextChannels:FindFirstChild("RBXGeneral")
        for _, Player in Players do
            if Api.CommandData.MutedPlayers then
                Api.CommandData.MutedPlayers[Player.UserId] = nil
            end
            local PlayerSource = GeneralChat and GeneralChat:FindFirstChild(Player.Name) :: TextSource
            if PlayerSource then
                PlayerSource.CanSend = true
            end
        end
    end,
}