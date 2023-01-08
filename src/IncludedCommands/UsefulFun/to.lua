--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "to",
    Category = "UsefulFunCommands",
    Description = "Teleports you to another player.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Player",
            Description = "Player to teleport to.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, TargetPlayers: {Player})
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

        --Telelport the executing player.
        if TargetLocation then
            local Player = CommandContext.Executor
            if Player ~= TargetPlayer then
                Util:TeleportPlayer(Player,TargetLocation * CFrame.new(math.random(-20, 20) / 10, 0, math.random(-20, 20) / 10))
            end
        end
    end,
}