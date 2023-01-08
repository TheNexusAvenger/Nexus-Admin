--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"walkspeed", "speed"},
    Category = "UsefulFunCommands",
    Description = "Sets the walkspeeds of the given players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to set the walkspeed.",
        },
        {
            Type = "number",
            Name = "Walkspeed",
            Description = "Walkspeed to set.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, WalkSpeed: number)
        for _, Player in Players do
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid.WalkSpeed = WalkSpeed
                end
            end
        end
    end,
}