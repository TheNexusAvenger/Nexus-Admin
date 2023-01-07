--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local StarterGui = game:GetService("StarterGui")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "mute",
    Category = "BasicCommands",
    Description = "Mutes a set of players. Admins can not be muted.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to mute.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApi)
        (IncludedCommandUtil:GetRemote("MutePlayer") :: RemoteEvent).OnClientEvent:Connect(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        IncludedCommandUtil:CreateRemote("RemoteEvent", "MutePlayer")
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Mute the players.
        local MutePlayerEvent = Util:GetRemote("MutePlayer") :: RemoteEvent
        for _, Player in Players do
            if Api.Authorization:GetAdminLevel(Player) >= 0 then
                Util:SendError("You can't crash admins.")
            else
                MutePlayerEvent:FireClient(Player)
            end
        end
    end,
}