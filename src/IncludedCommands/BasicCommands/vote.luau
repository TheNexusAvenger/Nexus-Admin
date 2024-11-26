--Implementation of a command.
--!strict

local Workspace = game:GetService("Workspace")
local TextService = game:GetService("TextService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))
local TextButtonFactory = require(script.Parent.Parent.Parent:WaitForChild("NexusButton"):WaitForChild("Factory"):WaitForChild("TextButtonFactory"))

local YesFactory = TextButtonFactory.CreateDefault(Color3.fromRGB(0, 200, 0))
YesFactory:SetTextDefault("Text", "Yes")
YesFactory:SetTextDefault("Font", Enum.Font.SciFi)

local NoFactory = TextButtonFactory.CreateDefault(Color3.fromRGB(200, 0, 0))
NoFactory:SetTextDefault("Text", "No")
NoFactory:SetTextDefault("Font", Enum.Font.SciFi)

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
        local StartVoteRemoteEvent = IncludedCommandUtil:GetRemote("StartVote") :: RemoteEvent
        local SendVoteResponseRemoteEvent = IncludedCommandUtil:GetRemote("SendVoteResponse") :: RemoteEvent
        local ResultWindows = {}
        local CompletePlayerVotesCallbacks = {}
        Api.CommandData.ResultWindows = ResultWindows
        Api.CommandData.CompletePlayerVotesCallbacks = CompletePlayerVotesCallbacks

        StartVoteRemoteEvent.OnClientEvent:Connect(function(AskingPlayer, Duration, Question)
            --Create the window.
            local ChoiceWindow = Api.Window:CreateWindow("Vote")

            --Determine the sizes.
            local WindowWidth = Workspace.CurrentCamera.ViewportSize.Y * 0.375
            local TextSize = ChoiceWindow.TextHeight
            local QuestionHeight = TextService:GetTextSize(Question, TextSize, Enum.Font.SourceSans, Vector2.new(WindowWidth * 0.95, math.huge)).Y
            
            --Create the labels.
            local QuestionText = Instance.new("TextLabel")
            QuestionText.BackgroundTransparency = 1
            QuestionText.AnchorPoint = Vector2.new(0.5, 0)
            QuestionText.Size = UDim2.new(0.95, 0, 0, QuestionHeight)
            QuestionText.Position = UDim2.new(0.5, 0, 0, 0)
            QuestionText.Font = Enum.Font.SourceSans
            QuestionText.Text = Question
            QuestionText.TextColor3 = Color3.fromRGB(255, 255, 255)
            QuestionText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            QuestionText.TextStrokeTransparency = 0
            QuestionText.TextWrapped = true
            QuestionText.TextSize = TextSize
            QuestionText.Parent = ChoiceWindow.ContentsAdorn

            local NoButton = NoFactory:Create()
            NoButton.Size = UDim2.new(0.35, 0, 0, TextSize * 2)
            NoButton.Position = UDim2.new(0.15, 0, 0, QuestionHeight + (TextSize * 0.25))
            NoButton.Parent = ChoiceWindow.ContentsAdorn

            local YesButton = YesFactory:Create()
            YesButton.Size = UDim2.new(0.35, 0, 0, TextSize * 2)
            YesButton.Position = UDim2.new(0.55, 0, 0, QuestionHeight + (TextSize * 0.25))
            YesButton.Parent = ChoiceWindow.ContentsAdorn

            local TimeText = Instance.new("TextLabel")
            TimeText.BackgroundTransparency = 1
            TimeText.AnchorPoint = Vector2.new(0.5, 0)
            TimeText.Size = UDim2.new(0.95, 0, 0, TextSize)
            TimeText.Position = UDim2.new(0.5, 0, 0, QuestionHeight + (2.75 * TextSize))
            TimeText.Font = Enum.Font.SourceSans
            TimeText.Text = "Voting not started."
            TimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
            TimeText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            TimeText.TextStrokeTransparency = 0
            TimeText.TextSize = TextSize
            TimeText.Parent = ChoiceWindow.ContentsAdorn

            --Show the window.
            ChoiceWindow:EnableClosing()
            ChoiceWindow:SetRelativeSize(0.375, 0.1 + ((QuestionHeight + (2.5 * TextSize)) / Workspace.CurrentCamera.ViewportSize.Y))
            ChoiceWindow:Show(UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5), Enum.NormalId.Top)

            --Connect the buttons.
            local DB = true
            NoButton.MouseButton1Down:Connect(function()
                if not DB then return end
                DB = false
                SendVoteResponseRemoteEvent:FireServer(AskingPlayer, Question, "No")
                ChoiceWindow:Close()
            end)
            YesButton.MouseButton1Down:Connect(function()
                if not DB then return end
                DB = false
                SendVoteResponseRemoteEvent:FireServer(AskingPlayer, Question, "Yes")
                ChoiceWindow:Close()
            end)

            --Perform the countdown.
            for i = Duration, 1, -1 do
                if i == 1 then
                    TimeText.Text = "1 second remaining."
                else
                    TimeText.Text = `{i} seconds remaining.`
                end
                task.wait(1)
            end
            TimeText.Text = "Voting has ended."

            --Close the window.
            ChoiceWindow:Close()
        end)
        SendVoteResponseRemoteEvent.OnClientEvent:Connect(function(VotingPlayer, Question, Response)
            local ResultsWindow = ResultWindows[Question]
            if ResultsWindow then
                ResultsWindow:UpdateVoterResult(VotingPlayer, Response)
            end
            local CompletePlayerVotesCallback = CompletePlayerVotesCallbacks[Question]
            if CompletePlayerVotesCallbacks then
                CompletePlayerVotesCallback(VotingPlayer, Response)
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
        local Api = Util:GetApi() :: Types.NexusAdminApiClient

        --Create the window.
        local ResultsWindow = Api.Window:CreateWindow("Results")

        --Determine the sizes.
        local WindowWidth = Workspace.CurrentCamera.ViewportSize.Y * 0.375
        local TextSize = ResultsWindow.TextHeight
        local QuestionHeight = TextService:GetTextSize(Question, TextSize, Enum.Font.SourceSans, Vector2.new(WindowWidth * 0.95, math.huge)).Y

        --Create the labels.
        local PlayerResults = {} :: {[Player]: string}
        local QuestionText = Instance.new("TextLabel")
        QuestionText.BackgroundTransparency = 1
        QuestionText.Size = UDim2.new(0, WindowWidth * 0.95, 0, QuestionHeight)
        QuestionText.Position = UDim2.new(0, WindowWidth * 0.025, 0, 0)
        QuestionText.Font = Enum.Font.SourceSans
        QuestionText.Text = Question
        QuestionText.TextColor3 = Color3.fromRGB(255, 255, 255)
        QuestionText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        QuestionText.TextStrokeTransparency = 0
        QuestionText.TextWrapped = true
        QuestionText.TextSize = TextSize
        QuestionText.Parent = ResultsWindow.ContentsAdorn

        local TimeText = Instance.new("TextLabel")
        TimeText.BackgroundTransparency = 1
        TimeText.Size = UDim2.new(0, WindowWidth * 0.95, 0, TextSize)
        TimeText.Position = UDim2.new(0, WindowWidth * 0.025, 0, QuestionHeight + (0.5 * TextSize))
        TimeText.Font = Enum.Font.SourceSans
        TimeText.Text = "Voting not started."
        TimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
        TimeText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        TimeText.TextStrokeTransparency = 0
        TimeText.TextSize = TextSize
        TimeText.Parent = ResultsWindow.ContentsAdorn

        local YesText = Instance.new("TextLabel")
        YesText.BackgroundTransparency = 1
        YesText.Size = UDim2.new(0, WindowWidth * 0.95, 0, TextSize)
        YesText.Position = UDim2.new(0, WindowWidth * 0.025, 0, QuestionHeight + (1.5 * TextSize))
        YesText.Font = Enum.Font.SourceSans
        YesText.Text = "0 voted yes."
        YesText.TextColor3 = Color3.fromRGB(255, 255, 255)
        YesText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        YesText.TextStrokeTransparency = 0
        YesText.TextSize = TextSize
        YesText.Parent = ResultsWindow.ContentsAdorn

        local NoText = Instance.new("TextLabel")
        NoText.BackgroundTransparency = 1
        NoText.Size = UDim2.new(0, WindowWidth * 0.95, 0, TextSize)
        NoText.Position = UDim2.new(0, WindowWidth * 0.025, 0, QuestionHeight + (2.5 * TextSize))
        NoText.Font = Enum.Font.SourceSans
        NoText.Text = "0 voted no."
        NoText.TextColor3 = Color3.fromRGB(255, 255, 255)
        NoText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        NoText.TextStrokeTransparency = 0
        NoText.TextSize = TextSize
        NoText.Parent = ResultsWindow.ContentsAdorn

        local UnvotedText = Instance.new("TextLabel")
        UnvotedText.BackgroundTransparency = 1
        UnvotedText.Size = UDim2.new(0, WindowWidth * 0.95, 0, TextSize)
        UnvotedText.Position = UDim2.new(0, WindowWidth * 0.025, 0, QuestionHeight + (3.5 * TextSize))
        UnvotedText.Font = Enum.Font.SourceSans
        UnvotedText.Text = "0 haven't voted."
        UnvotedText.TextColor3 = Color3.fromRGB(255, 255, 255)
        UnvotedText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        UnvotedText.TextStrokeTransparency = 0
        UnvotedText.TextSize = TextSize
        UnvotedText.Parent = ResultsWindow.ContentsAdorn

        local function UpdateText()
            --Get the totals.
            local Votes = {
                Yes = 0,
                No = 0,
                Undecided = 0,
            } :: {[string]: number}
            for Player,Response in PlayerResults do
                if Votes[Response] then
                    Votes[Response] = Votes[Response] + 1
                end
            end

            --Set the text.
            YesText.Text = `{Votes["Yes"]} voted yes.`
            NoText.Text = `{Votes["No"]} voted no.`
            if Votes["Undecided"] == 1 then
                UnvotedText.Text = "1 hasn't voted."
            else
                UnvotedText.Text = `{Votes["Undecided"]} haven't voted.`
            end
        end
        UpdateText()
        
        --Set up players voting.
        Api.CommandData.CompletePlayerVotesCallbacks[Question] = function(Player, Result): ()
            PlayerResults[Player] = Result
            UpdateText()
        end

        --Show the window.
        ResultsWindow:EnableClosing(function()
            Api.CommandData.CompletePlayerVotesCallbacks[Question] = nil
        end)
        ResultsWindow:SetRelativeSize(0.375, 0.1 + ((QuestionHeight + (3.5 * TextSize)) / Workspace.CurrentCamera.ViewportSize.Y))
        ResultsWindow:Show(UDim2.new(0.5, 0, 0.8, 0), Vector2.new(0.5, 1), Enum.NormalId.Bottom);

        --Invoke the server to start the vote.
        (Util:GetRemote("StartVote") :: RemoteEvent):FireServer(Players, Duration, Question)

        --Perform the countdown.
        for i = Duration, 1, -1 do
            if i == 1 then
                TimeText.Text = "1 second remaining."
            else
                TimeText.Text = `{i} seconds remaining.`
            end
            task.wait(1)
        end
        TimeText.Text = "Voting has ended."
    end,
}