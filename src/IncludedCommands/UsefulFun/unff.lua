--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unff",
    Category = "UsefulFunCommands",
    Description = "Removes all force fields from the given players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to remove force fields from.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            local Character = Player.Character
            if Character then
                for _, Ins in Character:GetChildren() do
                    if Ins:IsA("ForceField") then
                        Ins:Destroy()
                    end
                end
            end
        end
    end,
}