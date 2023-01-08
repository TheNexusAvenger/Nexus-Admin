--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unstun",
    Category = "UsefulFunCommands",
    Description = "Unstuns a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unstun.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
                if Humanoid then
                    Humanoid.PlatformStand = false
                end
            end
        end
    end,
}