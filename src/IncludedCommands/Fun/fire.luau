--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "fire",
    Category = "FunCommands",
    Description = "Adds a fire to a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give fire to.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        --Add the fire.
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart then
                    local Fire = Instance.new("Fire")
                    Fire.Name = "NexusAdminFire"
                    Fire.Parent = HumanoidRootPart
                end
            end
        end
    end,
}