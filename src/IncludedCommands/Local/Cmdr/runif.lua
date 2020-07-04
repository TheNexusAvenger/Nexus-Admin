--[[
TheNexusAvenger

Implementation of a Cmdr command.
--]]

local CmdrCommand = require(script.Parent.Parent:WaitForChild("CmdrCommand"))
local Command = CmdrCommand:Extend()

local conditions = {
	startsWith = function (text, arg)
		if text:sub(1, #arg) == arg then
			return text:sub(#arg + 1)
		end
	end
}



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper()

    self.Name = "runif"
	self.Aliases = {}
	self.Description = "Runs a given command string if a certain condition is met."
	self.Group = "DefaultUtil"
	self.Args = {
		{
			Type = "conditionFunction";
			Name = "Condition";
			Description = "The condition function"
		},
		{
			Type = "string";
			Name = "Argument";
			Description = "The argument to the condition function"
		},
		{
			Type = "string";
			Name = "Test against";
			Description = "The text to test against."
		},
		{
			Type = "string";
			Name = "Command";
			Description = "The command string to run if requirements are met. If omitted, return value from condition function is used.";
			Optional = true;
		},
	}
end

--[[
Runs the Cmdr command.
--]]
function Command:RunCommand(context, condition, arg, testAgainst, command)
    local conditionFunc = conditions[condition]

    if not conditionFunc then
        return ("Condition %q is not valid."):format(condition)
    end

    local text = conditionFunc(testAgainst, arg)

    if text then
        return context.Dispatcher:EvaluateAndRun(context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, command or text))
    end

    return ""
end



return Command