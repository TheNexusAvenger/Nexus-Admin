--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "crash",
    Category = "BasicCommands",
    Description = "Crashes a set of players. Admins can not be crashed.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to crash.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApi)
        (IncludedCommandUtil:GetRemote("CrashPlayer") :: RemoteEvent).OnClientEvent:Connect(function()
            while true do
                string.rep("Crash",3e12)
            end
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        IncludedCommandUtil:CreateRemote("RemoteEvent", "CrashPlayer")
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Crash the players.
        local CrashPlayerEvent = Util:GetRemote("CrashPlayer") :: RemoteEvent
        for _, Player in Players do
            if Api.Authorization:GetAdminLevel(Player) >= 0 then
                Util:SendError("You can't crash admins.")
            else
                CrashPlayerEvent:FireClient(Player)
            end
        end
    end,
}