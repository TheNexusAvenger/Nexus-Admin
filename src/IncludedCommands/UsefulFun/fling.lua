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
    self:InitializeSuper("fling","UsefulFunCommands","Flings a set of players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to fling.",
		},
    }
    
    --Create the remote event.
    local FlingPlayerEvent = Instance.new("RemoteEvent")
    FlingPlayerEvent.Name = "FlingPlayer"
    FlingPlayerEvent.Parent = self.API.EventContainer
    self.FlingPlayerEvent = FlingPlayerEvent
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
	self.super:Run(CommandContext)
	
    --Fling the players.
    for _,Player in pairs(Players) do
        self.FlingPlayerEvent:FireClient(Player)
    end
end



return Command