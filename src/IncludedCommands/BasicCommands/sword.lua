--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))
local Sword = script.Parent.Parent:WaitForChild("Resources"):WaitForChild("Sword")

return {
    Keyword = "sword",
    Category = "BasicCommands",
    Description = "Gives a sword to the given players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give swords.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Give the swords.
        for _, Player in Players do
            local Backpack = Player:FindFirstChild("Backpack")
            if Backpack then
                local NewSword = Sword:Clone()
                NewSword.CanBeDropped = Api.FeatureFlags:GetFeatureFlag("AllowDroppingSwords")
                NewSword.Parent = Backpack
            end
        end
    end,
}