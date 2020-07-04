--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local CommonState = require(script.Parent.Parent:WaitForChild("CommonState"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("unkeybind","Administrative","Unbinds the key from all commands.")

    self.Prefix = {"!",self.API.Configuration.CommandPrefix}
    self.Arguments = {
		{
			Type = "userInput",
			Name = "Key",
			Description = "Key to bind.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Key,Command)
    self.super:Run(CommandContext)

    --Unbind the key.
    if CommonState.Keybinds[Key] then
        CommonState.Keybinds[Key] = nil
        return "Key unbound."
    else
        return "Key was not bound."
    end
end



return Command