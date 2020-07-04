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
    self:InitializeSuper("stopcountdown","BasicCommands","Stops the current countdowns.")
    
    --Connect the remote event.
    self.API.EventContainer:WaitForChild("StopCountdown").OnClientEvent:Connect(function(Duration)
        --Stop and clear the countdowns.
        for _,Countdown in pairs(CommonState.Countdowns) do
            Countdown:Stop()
        end
        CommonState.Countdowns = {}
    end)
end



return Command