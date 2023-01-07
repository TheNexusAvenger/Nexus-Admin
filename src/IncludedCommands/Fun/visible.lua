--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "visible",
    Category = "FunCommands",
    Description = "Makes a set of players visible.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to make visible.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                for _, Ins in Player.Character:GetDescendants() do
                    if (Ins:IsA("BasePart") or Ins:IsA("Decal")) and Ins.Transparency > 1 then
                        (Ins :: BasePart).Transparency = Ins.Transparency - 1.1
                    end
                end
            end
        end
    end,
}