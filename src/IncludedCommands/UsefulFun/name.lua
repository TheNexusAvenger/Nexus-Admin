--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "name",
    Category = "UsefulFunCommands",
    Description = "Changes the name for a player.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to set the name.",
        },
        {
            Type = "string",
            Name = "Name",
            Description = "Name to set.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Name: string)
        Name = IncludedCommandUtil.ForContext(CommandContext):GetServerApi().Filter:FilterString(Name,CommandContext.Executor)
        for _, Player in Players do
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
                if Humanoid then
                    Humanoid.DisplayName = Name
                end
            end
        end
        return "Renamed using the name \""..Name.."\""
    end,
}