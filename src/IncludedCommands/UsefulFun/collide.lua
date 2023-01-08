--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "collide",
    Category = "UsefulFunCommands",
    Description = "Makes a set of players able to collide with each other.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to make collidable with each other.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Make the players collidable.
        for _, Player in Players do
            --Disconnect the events.
            if Api.CommandData.PlayerCollisionEvents[Player] then
                for _,Event in Api.CommandData.PlayerCollisionEvents[Player] do
                    Event:Disconnect()
                end
                Api.CommandData.PlayerCollisionEvents[Player] = {}
            end

            --Make the character collidable.
            if Player.Character then
                for _, Part in Player.Character:GetDescendants() do
                    if Part:IsA("BasePart") then
                        Part.CollisionGroup = "Default"
                    end
                end
            end
        end
    end,
}