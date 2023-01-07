--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"vote", "poll"},
    Category = "BasicCommands",
    Description = "Creates a poll for a set of players and returns the results.",
    Arguments = {
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
    },
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        local VoteChoiceWindow = require(IncludedCommandUtil.ClientResources:WaitForChild("VoteChoiceWindow")) :: any
        local StartVoteRemoteEvent = IncludedCommandUtil:GetRemote("StartVote") :: RemoteEvent
        local SendVoteResponseRemoteEvent = IncludedCommandUtil:GetRemote("SendVoteResponse") :: RemoteEvent
        local ResultWindows = {}
        Api.CommandData.ResultWindows = ResultWindows

        StartVoteRemoteEvent.OnClientEvent:Connect(function(AskingPlayer, Duration, Question)
            local ChoiceWindow = VoteChoiceWindow.new(Duration, Question)
            function ChoiceWindow.OnVote(_, Result)
                SendVoteResponseRemoteEvent:FireServer(AskingPlayer, Question, Result)
                ChoiceWindow:OnClose()
            end
            ChoiceWindow:Show()
            ChoiceWindow:StartCountdown()
        end)
        SendVoteResponseRemoteEvent.OnClientEvent:Connect(function(VotingPlayer, Question, Response)
            local ResultsWindow = ResultWindows[Question]
            if ResultsWindow then
                ResultsWindow:UpdateVoterResult(VotingPlayer, Response)
            end
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        --Set up the remote objects.
        local StartVoteRemoteEvent = IncludedCommandUtil:CreateRemote("RemoteEvent", "StartVote") :: RemoteEvent
        local SendVoteResponseRemoteEvent = IncludedCommandUtil:CreateRemote("RemoteEvent", "SendVoteResponse") :: RemoteEvent
        local AdminLevel = Api.Configuration:GetCommandAdminLevel("BasicCommands", "vote")
        
        StartVoteRemoteEvent.OnServerEvent:Connect(function(Player, VotingPlayers, Duration, Question)
            if Api.Authorization:IsPlayerAuthorized(Player, AdminLevel) then
                for TargetPlayer, FilterdQuestion in Api.Filter:FilterStringForPlayers(Question,Player,VotingPlayers) do
                    StartVoteRemoteEvent:FireClient(TargetPlayer,Player,Duration,FilterdQuestion)
                end
            end
        end)

        SendVoteResponseRemoteEvent.OnServerEvent:Connect(function(Player, TargetPlayer, Question, Response)
            if Api.Authorization:IsPlayerAuthorized(TargetPlayer, AdminLevel) then
                SendVoteResponseRemoteEvent:FireClient(TargetPlayer,Player,Question,Response)
            end
        end)
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Duration: number, Question: string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        local VoteResultsWindow = require(Util.ClientResources:WaitForChild("VoteResultsWindow")) :: any

        --Create the results window.
        local Window = VoteResultsWindow.new(Players, Duration, Question)
        Api.CommandData.ResultWindows[Question] = Window
        Window:Show()
        Window:StartCountdown();

        --Invoke the server to start the vote.
        (Util:GetRemote("StartVote") :: RemoteEvent):FireServer(Players, Duration, Question)
    end,
}