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
    self:InitializeSuper("countdown","BasicCommands","Creates a countdown with the given seconds.")

    self.Arguments = {
        {
            Type = "integer",
            Name = "Time",
            Description = "Time to count down.",
        },
    }
    
    --Create the remote event.
    local CountdownEvent = Instance.new("RemoteEvent")
    CountdownEvent.Name = "StartCountdown"
    CountdownEvent.Parent = self.API.EventContainer
    self.CountdownEvent = CountdownEvent
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Duration)
	self.super:Run(CommandContext)
	
    --Send the countdown.
    self.CountdownEvent:FireAllClients(Duration)
end



return Command