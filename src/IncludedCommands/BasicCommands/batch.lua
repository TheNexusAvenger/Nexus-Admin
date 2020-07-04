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
    self:InitializeSuper("batch","BasicCommands","Performs several commands at once.")

    self.Arguments = {
		{
			Type = "string",
			Name = "Command/Command/Command...",
			Description = "Commands to run.",
		},
	}
end



return Command