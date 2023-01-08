--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "fling",
    Category = "UsefulFunCommands",
    Description = "Flings a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to fling.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        (IncludedCommandUtil:GetRemote("FlingPlayer") :: RemoteEvent).OnClientEvent:Connect(function()
            local Character = Players.LocalPlayer.Character
            if Character then
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if HumanoidRootPart and Humanoid then
                    Humanoid.Sit = true
                    HumanoidRootPart.Velocity = Vector3.new(math.random(-200, 200), 500, math.random(-200, 200))
                end
            end
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        IncludedCommandUtil:CreateRemote("RemoteEvent", "FlingPlayer")
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)

        --Fling the players.
        for _, Player in Players do
            (Util:GetRemote("FlingPlayer") :: RemoteEvent):FireClient(Player)
        end
    end,
}