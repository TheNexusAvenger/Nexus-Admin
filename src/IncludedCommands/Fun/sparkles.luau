--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "sparkles",
    Category = "FunCommands",
    Description = "Adds a sparkles to a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to sparkles smoke to.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart then
                    local Sparkles = Instance.new("Sparkles")
                    Sparkles.Name = "NexusAdminSparkles"
                    Sparkles.Parent = HumanoidRootPart
                end
            end
        end
    end,
}