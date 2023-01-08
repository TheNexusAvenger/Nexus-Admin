--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "damage",
    Category = "UsefulFunCommands",
    Description = "Damages a given set of players, ignoring force fields.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to kill.",
        },
        {
            Type = "number",
            Name = "Damage",
            Description = "Amount of damage.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Damage: number)
        for _, Player in Players do
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid.Health = Humanoid.Health - Damage
                end
            end
        end
    end,
}