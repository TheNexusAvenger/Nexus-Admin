--Implementation of a command.
--!strict

local StarterGui = game:GetService("StarterGui")

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
        local UnmutePlayerEvent = Util:GetRemote("UnmutePlayer") :: RemoteEvent
        for _, Player in Players do
            UnmutePlayerEvent:FireClient(Player)
        end
    end,
}