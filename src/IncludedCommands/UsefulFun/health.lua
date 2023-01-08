--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "health",
    Category = "UsefulFunCommands",
    Description = "Heals a set of players, and sets their max health.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to set the health.",
        },
        {
            Type = "number",
            Name = "Health",
            Description = "Health to set.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Health: number)
        for _, Player in Players do
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
                if Humanoid then
                    Humanoid.MaxHealth = Health
                    Humanoid.Health = Health
                end
            end
        end
    end,
}