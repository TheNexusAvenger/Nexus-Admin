--[[
TheNexusAvenger

Implementation of a Cmdr command.
--]]

local CmdrCommand = require(script.Parent.Parent:WaitForChild("CmdrCommand"))
local Command = CmdrCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper()

    self.Name = "echo"
	self.Aliases = {}
	self.Description = "Echoes your text back to you."
	self.Group = "DefaultUtil"
	self.Args = {
		{
			Type = "string";
			Name = "Text";
			Description = "The text."
		},
	}
end

--[[
Runs the Cmdr command.
--]]
function Command:RunCommand(_, text)
    return text
end



return Command