--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "removehats",
    Category = "FunCommands",
    Description = "Removes the hats of a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to remove the hats of.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                for _, Hat in Player.Character:GetChildren() do
                    if Hat:IsA("Accoutrement") or Hat:IsA("Accessory") then
                        Hat:Destroy()
                    end
                end
            end
        end
    end,
}