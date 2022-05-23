--[[
TheNexusAvenger

Window for sending votes.
--]]

local Window = require(script.Parent.Parent.Parent:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("Window"))
local NexusButton = script.Parent.Parent.Parent:WaitForChild("NexusButton")
local TextButtonFactory = require(NexusButton:WaitForChild("Factory"):WaitForChild("TextButtonFactory"))

local YesFactory = TextButtonFactory.CreateDefault(Color3.new(0,200/255,0))
YesFactory:SetTextDefault("Text","Yes")
YesFactory:SetTextDefault("Font",Enum.Font.SciFi)
local NoFactory = TextButtonFactory.CreateDefault(Color3.new(200/255,0,0))
NoFactory:SetTextDefault("Text","No")
NoFactory:SetTextDefault("Font",Enum.Font.SciFi)

local VoteChoiceWindow = Window:Extend()
VoteChoiceWindow:SetClassName("VoteChoiceWindow")
VoteChoiceWindow.TextService = game:GetService("TextService")
VoteChoiceWindow.Players = game:GetService("Players")



--[[
Creates a votes results window.
--]]
function VoteChoiceWindow:__new(Duration,Question)
    self:InitializeSuper()
    self.Title = "Vote"
    self.Duration = Duration

    --Calculate the window size.
    local CameraHeight = self.Camera.ViewportSize.Y
    local TextSize = CameraHeight * 0.5 * 0.05
    local WindowWidth = CameraHeight * 0.375
    local QuestionHeight = self.TextService:GetTextSize(Question,TextSize,"SourceSans",Vector2.new(WindowWidth * 0.95,math.huge)).Y
    self.RequiredWindowHeight = QuestionHeight + (3.5 * TextSize)

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

    local NoButton = NoFactory:Create()
    NoButton.Size = UDim2.new(0.35,0,0,TextSize * 2)
    NoButton.Position = UDim2.new(0.15,0,0,QuestionHeight + (TextSize * 0.25))
    NoButton.Parent = self.ContentsAdorn

    local YesButton = YesFactory:Create()
    YesButton.Size = UDim2.new(0.35,0,0,TextSize * 2)
    YesButton.Position = UDim2.new(0.55,0,0,QuestionHeight + (TextSize * 0.25))
    YesButton.Parent = self.ContentsAdorn

    local TimeText = Instance.new("TextLabel")
    TimeText.BackgroundTransparency = 1
    TimeText.Size = UDim2.new(0,WindowWidth * 0.95,0,TextSize)
    TimeText.Position = UDim2.new(0,WindowWidth * 0.025,0,QuestionHeight + (2.75 * TextSize))
    TimeText.Font = "SourceSans"
    TimeText.Text = "Voting not started."
    TimeText.TextColor3 = Color3.new(1,1,1)
    TimeText.TextStrokeColor3 = Color3.new(0,0,0)
    TimeText.TextStrokeTransparency = 0
    TimeText.TextSize = TextSize
    TimeText.Parent = self.ContentsAdorn
    self.TimeText = TimeText

    --Connect the buttons.
    local DB = true
    NoButton.MouseButton1Down:Connect(function()
        if DB then
            DB = false
            self.object:OnVote("No")
        end
    end)
    YesButton.MouseButton1Down:Connect(function()
        if DB then
            DB = false
            self.object:OnVote("Yes")
        end
    end)

    --Update the time.
    self:UpdateTime(Duration)
end

--[[
Updates the time text.
--]]
function VoteChoiceWindow:UpdateTime(TimeRemaining)
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
function VoteChoiceWindow:StartCountdown()
    coroutine.wrap(function()
        --Count down the time.
        for i = self.Duration,1,-1 do
            self:UpdateTime(i)
            wait(1)
        end
        self:UpdateTime(0)

        --Close the window.
        if self.WindowFrame.Parent then
            self:OnClose()
        end
    end)()
end

--[[
Shows the window.
--]]
function VoteChoiceWindow:Show()
    --Create the ScreenGui.
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusAdminVoteChoiceWindow"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = self.Players.LocalPlayer:FindFirstChild("PlayerGui")
    self.ScreenGui = ScreenGui

    --Move the window off-screen.
    local CameraViewport = self.Camera.ViewportSize
    self.WindowFrame.Position = UDim2.new(0,(CameraViewport.X * 0.5) - (CameraViewport.Y * 0.375/2),0,CameraViewport.Y * -0.5)

    --Update the window and show the window.
    self.WindowFrame.Parent = ScreenGui
    local WindowHeight = self.ContentsAdorn.Size.Y.Offset - self.RequiredWindowHeight
    self.WindowFrame.Size = UDim2.new(0,CameraViewport.Y * 0.375,0,WindowHeight)
    self.WindowFrame:TweenPosition(UDim2.new(0,(CameraViewport.X * 0.5) - (CameraViewport.Y * 0.375/2),0,CameraViewport.Y * 0.5 - (WindowHeight/2)),"Out","Back",0.5,false)
end

--[[
Closes the window.
--]]
function VoteChoiceWindow:OnClose()
    self.WindowFrame:TweenPosition(UDim2.new(0,self.WindowFrame.AbsolutePosition.X,0,-self.WindowFrame.AbsolutePosition.Y * 1.2),"In","Back",0.5,false,function()
        self:Destroy()
        self.ScreenGui:Destroy()
    end)
end

--[[
Callback for the voting being done.
--]]
function VoteChoiceWindow:OnVote(Result)

end



return VoteChoiceWindow