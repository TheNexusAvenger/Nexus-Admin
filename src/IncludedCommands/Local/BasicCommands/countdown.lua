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
    self:InitializeSuper("countdown","BasicCommands","Creates a countdown with the given seconds.")

    self.Arguments = {
		{
			Type = "integer",
			Name = "Time",
			Description = "Time to count down.",
		},
    }
    
    --Connect the remote event.
    self.API.EventContainer:WaitForChild("StartCountdown").OnClientEvent:Connect(function(Duration)
        --Create the psuedo-object.
        local Countdown = {}
        Countdown.Active = true
        Countdown.API = self.API
        function Countdown:Start()
            for i = Duration,1,-1 do
                if not self.Active then return end
                self.API.Messages:DisplayHint(tostring(i),1)
                wait(1)
            end
        end
        function Countdown:Stop()
            self.Active = false
        end

        --Store the countdown and start it.
        table.insert(CommonState.Countdowns,Countdown)
        Countdown:Start()
    end)
end



return Command