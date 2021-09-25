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
    self:InitializeSuper("sh","BasicCommands","Creates a hint visible to everyone. No name is shown with the message.")

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
        self.API.Messages:DisplayHint(Player,FilteredMessage)
    end
end



return Command