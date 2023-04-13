--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Workspace = game:GetService("Workspace")

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "explode",
    Category = "UsefulFunCommands",
    Description = "Explodes a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to explode.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart") :: BasePart
                if HumanoidRootPart then
                    local Explosion = Instance.new("Explosion")
                    Explosion.Name = "NexusAdminExplosion"
                    Explosion.Position = HumanoidRootPart.Position
                    Explosion.Parent = Workspace
                end
            end
        end
    end,
}