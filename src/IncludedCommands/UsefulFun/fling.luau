--Implementation of a command.
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
        (IncludedCommandUtil:GetRemote("FlingPlayer") :: RemoteEvent).OnClientEvent:Connect(function(RandomVelocity: Vector3)
            local Character = Players.LocalPlayer.Character
            if not Character then return end
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if not HumanoidRootPart or not Humanoid then return end
            Humanoid.Sit = true
            HumanoidRootPart.AssemblyLinearVelocity = RandomVelocity
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        IncludedCommandUtil:CreateRemote("RemoteEvent", "FlingPlayer")
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local FlingPlayerEvent = Util:GetRemote("FlingPlayer") :: RemoteEvent

        --Fling the players.
        for _, Player in Players do
            local Character = Player.Character
            if not Character then continue end
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if not HumanoidRootPart or not Humanoid then continue end
            local RandomVelocity = Vector3.new(math.random(-200, 200), 500, math.random(-200, 200))
            Humanoid.Sit = true
            HumanoidRootPart.AssemblyLinearVelocity = RandomVelocity
            FlingPlayerEvent:FireClient(Player, RandomVelocity)
        end
    end,
}