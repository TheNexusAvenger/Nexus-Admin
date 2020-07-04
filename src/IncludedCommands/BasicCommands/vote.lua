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
    self:InitializeSuper({"vote","poll"},"BasicCommands","Creates a poll for a set of players and returns the results.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to run the vote for.",
		},
		{
			Type = "integer",
			Name = "Time",
			Description = "Time to run the poll.",
		},
		{
			Type = "string",
			Name = "Question",
			Description = "Question to ask.",
		},
    }
    
	--Set up the remote objects.
    local StartVoteRemoteEvent = Instance.new("RemoteEvent")
    StartVoteRemoteEvent.Name = "StartVote"
	StartVoteRemoteEvent.Parent = self.API.EventContainer
	
    local SendVoteResponseRemoteEvent = Instance.new("RemoteEvent")
    SendVoteResponseRemoteEvent.Name = "SendVoteResponse"
	SendVoteResponseRemoteEvent.Parent = self.API.EventContainer
	
	StartVoteRemoteEvent.OnServerEvent:Connect(function(Player,VotingPlayers,Duration,Question)
		if self.API.Authorization:IsPlayerAuthorized(Player,self.AdminLevel) then
			for TargetPlayer,FilterdQuestion in pairs(self.API.Filter:FilterStringForPlayers(Question,Player,VotingPlayers)) do
				StartVoteRemoteEvent:FireClient(TargetPlayer,Player,Duration,FilterdQuestion)
			end
		end
	end)

	SendVoteResponseRemoteEvent.OnServerEvent:Connect(function(Player,TargetPlayer,Question,Response)
		if self.API.Authorization:IsPlayerAuthorized(TargetPlayer,self.AdminLevel) then
			SendVoteResponseRemoteEvent:FireClient(TargetPlayer,Player,Question,Response)
		end
	end)
end



return Command