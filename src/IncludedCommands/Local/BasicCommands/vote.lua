--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local VoteResultsWindow = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("VoteResultsWindow"))
local VoteChoiceWindow = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("VoteChoiceWindow"))
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
    
    --Connect the remote objects.
    self.ResultWindows = {}
    self.API.EventContainer:WaitForChild("StartVote").OnClientEvent:Connect(function(AskingPlayer,Duration,Question)
        local ChoiceWindow = VoteChoiceWindow.new(Duration,Question)
        function ChoiceWindow.OnVote(_,Result)
            self.API.EventContainer:WaitForChild("SendVoteResponse"):FireServer(AskingPlayer,Question,Result)
            ChoiceWindow:OnClose()
        end
        ChoiceWindow:Show()
        ChoiceWindow:StartCountdown()
    end)
    self.API.EventContainer:WaitForChild("SendVoteResponse").OnClientEvent:Connect(function(VotingPlayer,Question,Response)
        local ResultsWindow = self.ResultWindows[Question]
        if ResultsWindow then
            ResultsWindow:UpdateVoterResult(VotingPlayer,Response)
        end
    end)
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Duration,Question)
    self.super:Run(CommandContext)

    --Create the results window.
    local Window = VoteResultsWindow.new(Players,Duration,Question)
    self.ResultWindows[Question] = Window
    Window:Show()
    Window:StartCountdown()

    --Invoke the server to start the vote.
    self.API.EventContainer:WaitForChild("StartVote"):FireServer(Players,Duration,Question)
end



return Command