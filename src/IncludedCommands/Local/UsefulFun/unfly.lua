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
    self:InitializeSuper("unfly","UsefulFunCommands","Removes flight from a set of players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unfly.",
        },
    }

    --Connect the remote event.
    self.API.EventContainer:WaitForChild("UnflyPlayer").OnClientEvent:Connect(function()
        if CommonState.CurrentFlight then
            CommonState.CurrentFlight:Destroy()
        end
    end)
end



return Command