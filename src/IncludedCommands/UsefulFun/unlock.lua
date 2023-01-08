--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unlock",
    Category = "UsefulFunCommands",
    Description = "Unlocks the character of the given players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unlock.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                for _,Ins in Player.Character:GetDescendants() do
                    if Ins:IsA("BasePart") then
                        Ins.Locked = false
                    end
                end
            end
        end
    end,
}