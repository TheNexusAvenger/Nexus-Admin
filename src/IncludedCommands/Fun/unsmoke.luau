--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unsmoke",
    Category = "FunCommands",
    Description = "Removes all smoke from a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to remove smoke from.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart then
                    for _, Smoke in HumanoidRootPart:GetChildren() do
                        if Smoke.Name == "NexusAdminSmoke" then
                            Smoke:Destroy()
                        end
                    end
                end
            end
        end
    end,
}