--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unfire",
    Category = "FunCommands",
    Description = "Removes all fire from a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to remove fire from.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart then
                    for _, Fire in HumanoidRootPart:GetChildren() do
                        if Fire.Name == "NexusAdminFire" then
                            Fire:Destroy()
                        end
                    end
                end
            end
        end
    end,
}