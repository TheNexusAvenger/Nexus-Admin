--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unfly",
    Category = "UsefulFunCommands",
    Description = "Removes flight from a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unfly.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        (IncludedCommandUtil:GetRemote("UnflyPlayer") :: RemoteEvent).OnClientEvent:Connect(function()
            if Api.CommandData.CurrentFlight then
                Api.CommandData.CurrentFlight:Destroy()
            end
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        IncludedCommandUtil:CreateRemote("RemoteEvent", "UnflyPlayer")
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)

        --Fly the players.
        for _, Player in Players do
            (Util:GetRemote("UnflyPlayer") :: RemoteEvent):FireClient(Player)
        end
    end,
}