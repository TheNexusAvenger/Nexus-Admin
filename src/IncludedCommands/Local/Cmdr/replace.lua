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

    self.Name = "replace"
	self.Aliases = {}
	self.Description = "Replaces text A with text B"
	self.Group = "DefaultUtil"
	self.Args = {
		{
			Type = "string";
			Name = "Haystack";
			Description = "The source string upon which to perform replacement."
		},
		{
			Type = "string";
			Name = "Needle";
			Description = "The string pattern search for."
		},
		{
			Type = "string";
			Name = "Replacement";
			Description = "The string to replace matches (%1 to insert matches)."
		},
	}
end

--[[
Runs the Cmdr command.
--]]
function Command:RunCommand(context, haystack, needle, replacement)
    return haystack:gsub(needle, replacement)
end



return Command