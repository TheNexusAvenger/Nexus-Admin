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
    self:InitializeSuper("stopcountdown","BasicCommands","Stops the current countdowns.")
    
    --Create the remote event.
    local StopCountdownEvent = Instance.new("RemoteEvent")
    StopCountdownEvent.Name = "StopCountdown"
    StopCountdownEvent.Parent = self.API.EventContainer
    self.StopCountdownEvent = StopCountdownEvent
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)
    
    --Send the countdown stop.
    self.StopCountdownEvent:FireAllClients()

    --Clear the countdown values.
    local PreviousCountdownsValue = self.API.EventContainer:FindFirstChild("PreviousCountdowns")
    if PreviousCountdownsValue then
        PreviousCountdownsValue.Value = "[]"
    end
end



return Command