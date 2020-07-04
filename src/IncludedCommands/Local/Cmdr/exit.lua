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

    self.Name = "exit"
	self.Aliases = {}
	self.Description = "Closes the command line. (Added by Nexus Admin.)"
	self.Group = "DefaultUtil"
	self.Args = {}
end

--[[
Runs the Cmdr command.
--]]
function Command:RunCommand(context)
    self.API.Cmdr:Toggle()
    return ""
end



return Command