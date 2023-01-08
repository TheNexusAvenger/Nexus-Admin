--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"thaw", "unfreeze"},
    Category = "UsefulFunCommands",
    Description = "Thaws the character of the given players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to thaw.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                for _,Ins in Player.Character:GetDescendants() do
                    if Ins:IsA("BasePart") then
                        Ins.Anchored = false
                    end
                end
            end
        end
    end,
}