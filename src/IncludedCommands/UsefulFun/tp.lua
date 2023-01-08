--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "tp",
    Category = "UsefulFunCommands",
    Description = "Teleports a set of players to another player.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to teleport.",
        },
        {
            Type = "nexusAdminPlayers",
            Name = "TargetPlayer",
            Description = "Player to teleport to",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, TargetPlayers: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)

        --Get the target location.
        local TargetLocation
        local TargetPlayer
        for _, NewTargetPlayer in TargetPlayers do
            if NewTargetPlayer.Character then
                local HumanoidRootPart = NewTargetPlayer.Character:FindFirstChild("HumanoidRootPart") :: BasePart
                if HumanoidRootPart then
                    TargetPlayer = NewTargetPlayer
                    TargetLocation = HumanoidRootPart.CFrame
                    break
                end
            end
        end

        --Telelport the players.
        local Radius = math.max(10, #Players)
        if TargetLocation then
            for _, Player in Players do
                if Player ~= TargetPlayer then
                    Util:TeleportPlayer(Player, TargetLocation * CFrame.new(math.random(-Radius, Radius) / 10, 0, math.random(-Radius, Radius) / 10))
                end
            end
        end
    end,
}