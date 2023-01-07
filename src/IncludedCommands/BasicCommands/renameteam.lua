--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "renameteam",
    Category = "BasicCommands",
    Description = "Renames a given team.",
    Arguments = {
        {
            Type = "team",
            Name = "Team",
            Description = "Team to rename.",
        },
        {
            Type = "string",
            Name = "Name",
            Description = "Name to use.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Team: Team, Name: string)
        Team.Name = IncludedCommandUtil.ForContext(CommandContext):GetServerApi().Filter:FilterString(Name, CommandContext.Executor)
    end,
}