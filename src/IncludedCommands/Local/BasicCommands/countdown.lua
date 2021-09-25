--[[
TheNexusAvenger

Implementation of a command.
--]]

local HttpService = game:GetService("HttpService")

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
        self:PerformCountdown(Duration)
    end)

    coroutine.wrap(function()
        --Wait for the previous countdowns to load.
        local PreviousCountdownsValue = self.API.EventContainer:WaitForChild("PreviousCountdowns")
        while PreviousCountdownsValue.Value == "" do
            wait()
        end

        --Start the existing countdowns.
        for _,CountdownEnd in pairs(HttpService:JSONDecode(PreviousCountdownsValue.Value)) do
            local RemainingTime = math.floor(CountdownEnd - os.time())
            if RemainingTime > 0 then
                self:PerformCountdown(RemainingTime)
            end
        end
    end)()
end

--[[
Performs a countdown.
--]]
function Command:PerformCountdown(Duration)
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
end



return Command