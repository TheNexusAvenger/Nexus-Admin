--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unrocket",
    Category = "FunCommands",
    Description = "Removes all rockets from a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to remove rockets from.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart and HumanoidRootPart:FindFirstChild("NexusAdminRocket") then
                    (HumanoidRootPart:FindFirstChild("NexusAdminRocket") :: BasePart):Destroy()
                end
            end
        end
    end,
}