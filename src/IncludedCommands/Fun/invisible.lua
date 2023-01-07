--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "invisible",
    Category = "FunCommands",
    Description = "Makes a set of players invisible.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to make invisible.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                for _, Ins in Player.Character:GetDescendants() do
                    if (Ins:IsA("BasePart") or Ins:IsA("Decal")) and Ins.Transparency <= 1 then
                        (Ins :: BasePart).Transparency = Ins.Transparency + 1.1
                    end
                end
            end
        end
    end,
}