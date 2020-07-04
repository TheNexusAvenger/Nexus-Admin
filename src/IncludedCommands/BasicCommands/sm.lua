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
    self:InitializeSuper("sm","BasicCommands","Creates a message visible to everyone. The displayed name is \"Nexus Admin\".")

    self.Arguments = {
		{
			Type = "string",
			Name = "Message",
			Description = "Announcement text.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Message)
    self.super:Run(CommandContext)
    
    --Filter and send the message.
	for Player,FilteredMessage in pairs(self.API.Filter:FilterStringForPlayers(Message,CommandContext.Executor,self.Players:GetPlayers())) do
        self.API.Messages:DisplayMessage(Player,"Nexus Admin",FilteredMessage)
	end
end



return Command