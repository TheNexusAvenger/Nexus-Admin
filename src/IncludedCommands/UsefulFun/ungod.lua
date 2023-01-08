--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "ungod",
    Category = "UsefulFunCommands",
    Description = "Sets the max health of the given players 100.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to ungod.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
                if Humanoid then
                    Humanoid.MaxHealth = 100
                    Humanoid.Health = 100
                end
            end
        end
    end,
}