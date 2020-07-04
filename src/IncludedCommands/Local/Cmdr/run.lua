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

    self.Name = "run"
	self.Aliases = {}
	self.AutoExec = {
		"alias discard replace ${run $1} .* \\\"\\\""
	}
	self.Description = "Runs a given command string (replacing embedded commands).";
	self.Group = "DefaultUtil"
	self.Args = {
		{
			Type = "string";
			Name = "Command";
			Description = "The command string to run"
		},
	}
end

--[[
Runs the Cmdr command.
--]]
function Command:RunCommand(context, command)
    return context.Dispatcher:EvaluateAndRun(context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, command))
end



return Command