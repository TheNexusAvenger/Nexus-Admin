--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local TeleportService = game:GetService("TeleportService")

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "place",
    Category = "UsefulFunCommands",
    Description = "Teleports a set of players to the given place.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to teleport.",
        },
        {
            Type = "integer",
            Name = "PlaceId",
            Description = "Place to teleport to.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, PlaceId: number)
        for _, Player in Players do
            TeleportService:Teleport(PlaceId,Player)
        end
    end,
}