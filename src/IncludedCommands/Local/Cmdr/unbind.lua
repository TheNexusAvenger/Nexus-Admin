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

    self.Name = "unbind"
	self.Aliases = {}
	self.Description = "Unbinds an input previously bound with Bind"
	self.Group = "DefaultUtil"
	self.Args = {
		{
			Type = "userInput ! bindableResource @ player";
			Name = "Input/Key";
			Description = "The key or input type you'd like to unbind."
		}
	}
end

--[[
Runs the Cmdr command.
--]]
function Command:RunCommand(context, inputEnum)
    local binds = context:GetStore("CMDR_Binds")

    if binds[inputEnum] then
        binds[inputEnum]:Disconnect()
        binds[inputEnum] = nil
        return "Unbound command from input."
    else
        return "That input wasn't bound."
    end
end



return Command