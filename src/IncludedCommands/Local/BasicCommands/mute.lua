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
    self:InitializeSuper("mute","BasicCommands","Mutes a set of players. Admins can not be muted.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to mute.",
		},
    }
    
    --Connect the remote event.
    self.API.EventContainer:WaitForChild("MutePlayer").OnClientEvent:Connect(function()
        self.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,false)
    end)
end



return Command