--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "smoke",
    Category = "FunCommands",
    Description = "Adds a smoke to a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give smoke to.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart then
                    local Smoke = Instance.new("Smoke")
                    Smoke.Color = Color3.fromRGB(100, 100, 100)
                    Smoke.RiseVelocity = 5
                    Smoke.Opacity = 0.75
                    Smoke.Name = "NexusAdminSmoke"
                    Smoke.Parent = HumanoidRootPart
                end
            end
        end
    end,
}