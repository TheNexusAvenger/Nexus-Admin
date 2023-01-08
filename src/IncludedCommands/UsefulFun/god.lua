--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "god",
    Category = "UsefulFunCommands",
    Description = "Heals a set of players, and makes their health infinite.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to god.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
                if Humanoid then
                    Humanoid.MaxHealth = math.huge
                    Humanoid.Health = math.huge
                end
            end
        end
    end,
}