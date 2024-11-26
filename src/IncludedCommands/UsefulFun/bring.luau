--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "bring",
    Category = "UsefulFunCommands",
    Description = "Teleports a set of players to you.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to teleport.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)

        --Get the target location.
        local TargetLocation
        if CommandContext.Executor.Character then
            local HumanoidRootPart = CommandContext.Executor.Character:FindFirstChild("HumanoidRootPart") :: BasePart
            if HumanoidRootPart then
                TargetLocation = HumanoidRootPart.CFrame
            end
        end

        --Telelport the players.
        local Radius = math.max(10, #Players)
        if TargetLocation then
            for _, Player in Players do
                if Player ~= CommandContext.Executor then
                    Util:TeleportPlayer(Player, TargetLocation * CFrame.new(math.random(-Radius, Radius) / 10, 0, math.random(-Radius, Radius) / 10))
                end
            end
        end
    end,
}