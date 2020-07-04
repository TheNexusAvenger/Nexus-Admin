--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("renameteam","BasicCommands","Renames a given team.")

    self.Arguments = {
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
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Team,Name)
	self.super:Run(CommandContext)
	
    --Rename the team.
    local FilteredName = self.API.Filter:FilterString(Name,CommandContext.Executor)
    Team.Name = FilteredName
end



return Command