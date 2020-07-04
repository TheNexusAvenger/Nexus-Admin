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
    
    --Create the remote event.
    local MutePlayerEvent = Instance.new("RemoteEvent")
    MutePlayerEvent.Name = "MutePlayer"
    MutePlayerEvent.Parent = self.API.EventContainer
    self.MutePlayerEvent = MutePlayerEvent
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
	self.super:Run(CommandContext)
	
    --Mute the players.
    for _,Player in pairs(Players) do
        if self.API.Authorization:GetAdminLevel(Player) >= 0 then
            self:SendError("You can't mute admins.")
        else
            self.MutePlayerEvent:FireClient(Player)
        end
    end
end



return Command