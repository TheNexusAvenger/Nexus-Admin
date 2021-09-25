--[[
TheNexusAvenger

Implementation of a command.
--]]

local HttpService = game:GetService("HttpService")

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

    --Create the storage value to allow countdowns for players who join after they start.
    local PreviousCountdownsValue = Instance.new("StringValue")
    PreviousCountdownsValue.Name = "PreviousCountdowns"
    PreviousCountdownsValue.Value = "[]"
    PreviousCountdownsValue.Parent = self.API.EventContainer
    self.PreviousCountdownsValue = PreviousCountdownsValue
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Duration)
    self.super:Run(CommandContext)
    
    --Send the countdown.
    self.CountdownEvent:FireAllClients(Duration)
    
    --Store the countdown.
    local PreviousCountdowns = HttpService:JSONDecode(self.PreviousCountdownsValue.Value)
    table.insert(PreviousCountdowns,os.time() + Duration)
    self.PreviousCountdownsValue.Value = HttpService:JSONEncode(PreviousCountdowns)
end



return Command