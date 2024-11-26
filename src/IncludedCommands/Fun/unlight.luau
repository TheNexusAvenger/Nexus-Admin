--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unlight",
    Category = "FunCommands",
    Description = "Removes all light from a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to remove light from.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart then
                    for _, Light in HumanoidRootPart:GetChildren() do
                        if Light.Name == "NexusAdminLight" then
                            Light:Destroy()
                        end
                    end
                end
            end
        end
    end,
}