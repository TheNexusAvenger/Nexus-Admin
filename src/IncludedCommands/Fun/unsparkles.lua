--[[
TheNexusAvenger

Implementation of a command.
--]]

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unsparkles",
    Category = "FunCommands",
    Description = "Removes all sparkles from a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to remove sparkles from.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart then
                    for _, Sparkles in HumanoidRootPart:GetChildren() do
                        if Sparkles.Name == "NexusAdminSparkles" then
                            Sparkles:Destroy()
                        end
                    end
                end
            end
        end
    end,
}