--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "flip",
    Category = "UsefulFunCommands",
    Description = "Flips a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to flip.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart") :: BasePart
                if HumanoidRootPart then
                    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.pi)
                end
            end
        end
    end,
}