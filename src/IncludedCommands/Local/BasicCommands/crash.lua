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
    self:InitializeSuper("crash","BasicCommands","Crashes a set of players. Admins can not be crashed.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to crash.",
		},
    }
    
    --Connect the remote event.
    self.API.EventContainer:WaitForChild("CrashPlayer").OnClientEvent:Connect(function()
        while true do
            string.rep("Crash",3e12)
        end
    end)
end



return Command