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

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Commands)
    self.super:Run(CommandContext)

    --Run the commands.
    for _,Command in pairs(string.split(Commands,"/")) do
        local Message = self.API.Executor:ExecuteCommandWithOrWithoutPrefix(Command,self.Players.LocalPlayer,CommandContext:GetData())
        if Message ~= "" then
            self:SendMessage(Message)
        end
    end
end



return Command