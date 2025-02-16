--Implementation of a command.
--!strict

local StarterGui = game:GetService("StarterGui")
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
    ClientLoad = function(Api: Types.NexusAdminApi)
        (IncludedCommandUtil:GetRemote("UnmutePlayer") :: RemoteEvent).OnClientEvent:Connect(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        IncludedCommandUtil:CreateRemote("RemoteEvent", "UnmutePlayer")
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)

        --Mute the players.
        local TextChannels = TextChatService:FindFirstChild("TextChannels")
        local GeneralChat = TextChannels and TextChannels:FindFirstChild("RBXGeneral")
        local UnmutePlayerEvent = Util:GetRemote("UnmutePlayer") :: RemoteEvent
        for _, Player in Players do
            local PlayerSource = GeneralChat and GeneralChat:FindFirstChild(Player.Name) :: TextSource
            if PlayerSource then
                PlayerSource.CanSend = true
            else
                UnmutePlayerEvent:FireClient(Player) --TODO: Remove when legacy chat removed.
            end
        end
    end,
}