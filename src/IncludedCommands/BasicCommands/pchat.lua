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
    self:InitializeSuper({"pchat","pc"},"BasicCommands","Starts a private chat between a set of players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to run the vote for.",
		},
		{
			Type = "string",
			Name = "Question",
			Description = "Message to send.",
		},
    }

    --Set up the remote objects.
    local SendPrivateMessageRemoteEvent = Instance.new("RemoteEvent")
    SendPrivateMessageRemoteEvent.Name = "SendPrivateMessage"
	SendPrivateMessageRemoteEvent.Parent = self.API.EventContainer
	
	SendPrivateMessageRemoteEvent.OnServerEvent:Connect(function(Player,TargetPlayer,Message)
		Message = self.API.Filter:FilterString(Message,Player,TargetPlayer)
		SendPrivateMessageRemoteEvent:FireClient(TargetPlayer,Player,Message)
	end)
end



return Command