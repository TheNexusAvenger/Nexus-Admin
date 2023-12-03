--[[
TheNexusAvenger

Window for showing the active results of a vote.
--]]

local Window = require(script.Parent.Parent.Parent:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("Window"))

local VoteResultsWindow = Window:Extend()
VoteResultsWindow:SetClassName("VoteResultsWindow")
VoteResultsWindow.TextService = game:GetService("TextService")
VoteResultsWindow.Players = game:GetService("Players")



--[[
Creates a votes results window.
--]]
function VoteResultsWindow:__new(Players,Duration,Question)
    self:InitializeSuper()
    self.Title = "Results"
    self.Duration = Duration

    --Initialize the results.
    self.Results = {}
    for _,Player in pairs(Players) do
        self.Results[Player] = "Undecided"
    end

    --Calculate the window size.
    local CameraHeight = self.Camera.ViewportSize.Y
    local TextSize = CameraHeight * 0.5 * 0.05
    local WindowWidth = CameraHeight * 0.375
    local QuestionHeight = self.TextService:GetTextSize(Question,TextSize,"SourceSans",Vector2.new(WindowWidth * 0.95,math.huge)).Y
    self.RequiredWindowHeight = QuestionHeight + (4.5 * TextSize)

    --Create the labels.
    local QuestionText = Instance.new("TextLabel")
    QuestionText.BackgroundTransparency = 1
    QuestionText.Size = UDim2.new(0,WindowWidth * 0.95,0,QuestionHeight)
    QuestionText.Position = UDim2.new(0,WindowWidth * 0.025,0,0)
    QuestionText.Font = "SourceSans"
    QuestionText.Text = Question
    QuestionText.TextColor3 = Color3.new(1,1,1)
    QuestionText.TextStrokeColor3 = Color3.new(0,0,0)
    QuestionText.TextStrokeTransparency = 0
    QuestionText.TextWrapped = true
    QuestionText.TextSize = TextSize
    QuestionText.Parent = self.ContentsAdorn

    local TimeText = Instance.new("TextLabel")
    TimeText.BackgroundTransparency = 1
    TimeText.Size = UDim2.new(0,WindowWidth * 0.95,0,TextSize)
    TimeText.Position = UDim2.new(0,WindowWidth * 0.025,0,QuestionHeight + (0.5 * TextSize))
    TimeText.Font = "SourceSans"
    TimeText.Text = "Voting not started."
    TimeText.TextColor3 = Color3.new(1,1,1)
    TimeText.TextStrokeColor3 = Color3.new(0,0,0)
    TimeText.TextStrokeTransparency = 0
    TimeText.TextSize = TextSize
    TimeText.Parent = self.ContentsAdorn
    self.TimeText = TimeText

    local YesText = Instance.new("TextLabel")
    YesText.BackgroundTransparency = 1
    YesText.Size = UDim2.new(0,WindowWidth * 0.95,0,TextSize)
    YesText.Position = UDim2.new(0,WindowWidth * 0.025,0,QuestionHeight + (1.5 * TextSize))
    YesText.Font = "SourceSans"
    YesText.Text = "0 voted yes."
    YesText.TextColor3 = Color3.new(1,1,1)
    YesText.TextStrokeColor3 = Color3.new(0,0,0)
    YesText.TextStrokeTransparency = 0
    YesText.TextSize = TextSize
    YesText.Parent = self.ContentsAdorn
    self.YesText = YesText

    local NoText = Instance.new("TextLabel")
    NoText.BackgroundTransparency = 1
    NoText.Size = UDim2.new(0,WindowWidth * 0.95,0,TextSize)
    NoText.Position = UDim2.new(0,WindowWidth * 0.025,0,QuestionHeight + (2.5 * TextSize))
    NoText.Font = "SourceSans"
    NoText.Text = "0 voted no."
    NoText.TextColor3 = Color3.new(1,1,1)
    NoText.TextStrokeColor3 = Color3.new(0,0,0)
    NoText.TextStrokeTransparency = 0
    NoText.TextSize = TextSize
    NoText.Parent = self.ContentsAdorn
    self.NoText = NoText

    local UnvotedText = Instance.new("TextLabel")
    UnvotedText.BackgroundTransparency = 1
    UnvotedText.Size = UDim2.new(0,WindowWidth * 0.95,0,TextSize)
    UnvotedText.Position = UDim2.new(0,WindowWidth * 0.025,0,QuestionHeight + (3.5 * TextSize))
    UnvotedText.Font = "SourceSans"
    UnvotedText.Text = "0 haven't voted."
    UnvotedText.TextColor3 = Color3.new(1,1,1)
    UnvotedText.TextStrokeColor3 = Color3.new(0,0,0)
    UnvotedText.TextStrokeTransparency = 0
    UnvotedText.TextSize = TextSize
    UnvotedText.Parent = self.ContentsAdorn
    self.UnvotedText = UnvotedText

    --Update the results.
    self:UpdateTime(Duration)
    self:UpdateTotals()
end

--[[
Updates the time text.
--]]
function VoteResultsWindow:UpdateTime(TimeRemaining)
    if TimeRemaining == 0 then
        self.TimeText.Text = "Voting has ended."
    elseif TimeRemaining == 1 then
        self.TimeText.Text = "1 second remaining."
    else
        self.TimeText.Text = tostring(TimeRemaining).." seconds remaining."
    end
end

--[[
Starts the countdown.
--]]
function VoteResultsWindow:StartCountdown()
    coroutine.wrap(function()
        for i = self.Duration,1,-1 do
            self:UpdateTime(i)
            wait(1)
        end
        self:UpdateTime(0)
    end)()
end

--[[
Updates the totals.
--]]
function VoteResultsWindow:UpdateTotals()
    --Get the totals.
    local Votes = {
        Yes = 0,
        No = 0,
        Undecided = 0,
    }
    for Player,Response in pairs(self.Results) do
        if Votes[Response] then
            Votes[Response] = Votes[Response] + 1
        end
    end

    --Set the text.
    self.YesText.Text = tostring(Votes["Yes"]).." voted yes."
    self.NoText.Text = tostring(Votes["No"]).." voted no."
    if Votes["Undecided"] == 1 then
        self.UnvotedText.Text = "1 hasn't voted."
    else
        self.UnvotedText.Text = tostring(Votes["Undecided"]).." haven't voted."
    end
end

--[[
Shows the window.
--]]
function VoteResultsWindow:Show()
    --Create the ScreenGui.
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusAdminVoteResultsWindow"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = self.Players.LocalPlayer:FindFirstChild("PlayerGui")
    self.ScreenGui = ScreenGui

    --Update the window and show the window.
    local CameraViewport = self.Camera.ViewportSize
    local WindowHeight = math.abs(self.ContentsAdorn.Size.Y.Offset - self.RequiredWindowHeight)
    self.WindowFrame.Size = UDim2.new(0, CameraViewport.Y * 0.375, 0, WindowHeight)
    self:MoveTo(Enum.NormalId.Top, 0.5, 0.5)
    self.WindowFrame.Parent = ScreenGui
    self:TweenTo(Enum.NormalId.Top, 0.45)
end

--[[
Closes the window.
--]]
function VoteResultsWindow:OnClose()
    self:TweenOut(Enum.NormalId.Top, function()
        self:Destroy()
        self.ScreenGui:Destroy()
    end)
end

--[[
Updates the result of a voter.
--]]
function VoteResultsWindow:UpdateVoterResult(VotingPlayer,Response)
    if self.Results[VotingPlayer] then
        self.Results[VotingPlayer] = Response
        self:UpdateTotals()
    end
end



return VoteResultsWindow