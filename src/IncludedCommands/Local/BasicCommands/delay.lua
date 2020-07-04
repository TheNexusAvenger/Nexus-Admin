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
    self:InitializeSuper("delay","BasicCommands","Runs a command after a given amount of seconds.")

    self.Arguments = {
		{
			Type = "number",
			Name = "Delay",
			Description = "Delay before running the command.",
		},
		{
			Type = "string",
			Name = "Command",
			Description = "Command to run.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Delay,Command)
    self.super:Run(CommandContext)

    --Schedule the command.
    delay(Delay,function()
        local Message = self.API.Executor:ExecuteCommandWithOrWithoutPrefix(Command,self.Players.LocalPlayer,CommandContext:GetData())
        if Message ~= "" then
            self:SendMessage(Message)
        end
    end)

    --Return the command being scheduled.
    if Delay == 1 then
        return "Command scheduled to run in 1 second."
    else
        return "Command scheduled to run in "..Delay.." seconds."
    end
end



return Command