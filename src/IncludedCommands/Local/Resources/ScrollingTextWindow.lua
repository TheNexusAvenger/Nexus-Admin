--[[
TheNexusAvenger

Window for showing scrolling text.
Intended to be used with the integrated commands.
--]]

local ResizableWindow = require(script.Parent.Parent.Parent:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("ResizableWindow"))

local ScrollingTextWindow = ResizableWindow:Extend()
ScrollingTextWindow:SetClassName("ScrollingTextWindow")
ScrollingTextWindow.TextService = game:GetService("TextService")
ScrollingTextWindow.Players = game:GetService("Players")



--[[
Creates a scrolling text window.
--]]
function ScrollingTextWindow:__new(DontCreateSearch, UseTextBoxes)
    self:InitializeSuper()

    self.CurrentTextLabels = {}
    self.TextHeight = self.Camera.ViewportSize.Y * 0.5 * 0.045
    self.UseTextBoxes = UseTextBoxes
    if self.UseTextBoxes == nil then
        self.UseTextBoxes = true
    end

    --Create the scrolling frame.
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Parent = self.ContentsAdorn
    self.ScrollingFrame = ScrollingFrame

    local ScrollingClipFrame = Instance.new("Frame")
    ScrollingClipFrame.BackgroundTransparency = 1
    ScrollingClipFrame.ClipsDescendants = true
    ScrollingClipFrame.Parent = self.ContentsAdorn
    self.ScrollingClipFrame = ScrollingClipFrame

    local ScrollingAdornFrame = Instance.new("Frame")
    ScrollingAdornFrame.BackgroundTransparency = 1
    ScrollingAdornFrame.Size = UDim2.new(1, 0, 0, self.TextHeight)
    ScrollingAdornFrame.Parent = ScrollingClipFrame
    self.ScrollingAdornFrame = ScrollingAdornFrame
    self.ScrollingAdornTextLabels = {}

    if DontCreateSearch then
        ScrollingFrame.Size = UDim2.new(1,-10,1,-10)
        ScrollingFrame.Position = UDim2.new(0,5,0,5)
    else
        ScrollingFrame.Size = UDim2.new(1,-10,1,-10 - (1.3 * self.TextHeight))
        ScrollingFrame.Position = UDim2.new(0,5,0,5 + (1.3 * self.TextHeight))

        --Create the search box.
        local SearchIcon = Instance.new("ImageLabel")
        SearchIcon.Size = UDim2.new(0,self.TextHeight,0,self.TextHeight)
        SearchIcon.Position = UDim2.new(0,0.25 * self.TextHeight,0,0.25 * self.TextHeight)
        SearchIcon.BackgroundTransparency = 1
        SearchIcon.Image = "rbxasset://textures/StudioToolbox/Search.png"
        SearchIcon.Parent = self.ContentsAdorn

        local SearchBar = Instance.new("TextBox")
        SearchBar.BackgroundTransparency = 0.5
        SearchBar.Size = UDim2.new(1,-2 * self.TextHeight,0,1.2 * self.TextHeight)
        SearchBar.Position = UDim2.new(0,1.5 * self.TextHeight,0,0.15 * self.TextHeight)
        SearchBar.BackgroundColor3 = Color3.new(0,0,0)
        SearchBar.BorderSizePixel = 0
        SearchBar.Text = ""
        SearchBar.Font = "SourceSans"
        SearchBar.TextSize = self.TextHeight
        SearchBar.TextColor3 = Color3.new(1,1,1)
        SearchBar.ClearTextOnFocus = false
        SearchBar.ClipsDescendants = true
        SearchBar.TextXAlignment = "Left"
        SearchBar.Parent = self.ContentsAdorn
        self.SearchBar = SearchBar
        SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
            self:UpdateText(false)
        end)
    end

    --Set the defaults.
    self.TextDefaults = {
        TextColor3 = Color3.new(1, 1, 1),
        TextStrokeColor3 = Color3.new(0, 0, 0),
        TextStrokeTransparency = 0,
        Font = Enum.Font.SourceSans,
    }

    --Connect the events.
	ScrollingFrame:GetPropertyChangedSignal("Parent"):Connect(function()
        self:UpdateAdornSize()
    end)
	ScrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        self:UpdateAdornSize()
    end)
	ScrollingFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        self:UpdateAdornSize()
    end)
	ScrollingFrame:GetPropertyChangedSignal("ZIndex"):Connect(function()
        self:UpdateAdornSize()
    end)
	ScrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
        self:UpdateAdornText()
    end)
	ScrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        self:UpdateAdornText()
    end)
	self:UpdateAdornSize()
end

--[[
Shows the window.
--]]
function ScrollingTextWindow:Show()
    --Create the ScreenGui.
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusAdminIncludedCommandWindow"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = self.Players.LocalPlayer:FindFirstChild("PlayerGui")
    self.ScreenGui = ScreenGui

    --Update the window and show the window.
    self:MoveTo(Enum.NormalId.Left)
    self.WindowFrame.Parent = ScreenGui
    self:OnRefresh()
    self:TweenTo(Enum.NormalId.Left)
end

--[[
Returns the lines to display.
--]]
function ScrollingTextWindow:GetTextLines(SearchTerm,ForceRefresh)
    return {}
end

--[[
Updates the text adorn size and position.
--]]
function ScrollingTextWindow:UpdateAdornSize()
    self.ScrollingClipFrame.Position = self.ScrollingFrame.Position
    self.ScrollingClipFrame.Size = UDim2.new(0, self.ScrollingFrame.AbsoluteWindowSize.X, 0, self.ScrollingFrame.AbsoluteWindowSize.Y)
    self.ScrollingAdornFrame.Size = UDim2.new(0, self.MaxLineWidth or 0, 0, self.TextHeight)
end

--[[
Updates the text adorn contents.
--]]
function ScrollingTextWindow:UpdateAdornText()
    self:UpdateAdornSize()

    --Create the text labels.
    local StartIndex = self.ScrollingFrame.CanvasPosition.Y / self.TextHeight
    local RequiredLabels = math.ceil(self.ScrollingFrame.AbsoluteWindowSize.Y / self.TextHeight) + 1
    local TextLabels = self.ScrollingAdornTextLabels
    for i = #TextLabels + 1, RequiredLabels do
        local TextLabel = Instance.new(self.UseTextBoxes and "TextBox" or "TextLabel")
        TextLabel.BackgroundTransparency = 1
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.Position = UDim2.new(0, 0, i - 1, 0)
        if self.UseTextBoxes then
            TextLabel.ClearTextOnFocus = false
            TextLabel.TextEditable = false
        end
        TextLabel.TextSize = self.TextHeight
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Parent = self.ScrollingAdornFrame
        table.insert(TextLabels, TextLabel)
    end
    for i = #TextLabels, RequiredLabels + 1, -1 do
        TextLabels[i]:Destroy()
        TextLabels[i] = nil
    end

    --Uppdate the text labels.
    local Lines = self.Lines or {}
    local Defaults = self.TextDefaults
    for i = 1, RequiredLabels do
        local Index = i + math.floor(StartIndex)
        local LineEntry = Lines[Index]
        local TextLabel = TextLabels[i]
        if LineEntry then
            for Key, _ in LineEntry do
                if not Defaults[Key] then
                    Defaults[Key] = TextLabel[Key]
                end
            end
            for Key, Value in Defaults do
                TextLabel[Key] = LineEntry[Key] or Value
            end
        else
            TextLabel.Text = ""
        end
    end
    self.ScrollingAdornFrame.Position = UDim2.new(0, -self.ScrollingFrame.CanvasPosition.X, 0, -self.TextHeight * (StartIndex % 1))
end

--[[
Updates the text.
--]]
function ScrollingTextWindow:UpdateText(ForceRefresh)
    --Get the lines.
    local BaseLines = self:GetTextLines(self.SearchBar and self.SearchBar.Text or "",ForceRefresh or false)

    --Split the lines.
    local Lines = {}
    for _, Line in BaseLines do
        if type(Line) == "string" then
            Line = {Text=Line}
        end
        for _, SubLine in string.split(Line.Text or "", "\n") do
            local LineData = {}
            for Key, Value in Line do
                LineData[Key] = Value
            end
            LineData.Text = SubLine
            table.insert(Lines, LineData)
        end
    end

    --Determine the max width of the lines.
    local MaxWidth = 0
    for _, Line in Lines  do
        local Text = Line.Text
        local Font = Line.Font or Enum.Font.SourceSans
        local LineLength = self.TextService:GetTextSize(Text, self.TextHeight, Font, Vector2.new(math.huge, self.TextHeight)).X
        MaxWidth = math.max(MaxWidth, LineLength)
    end
    self.Lines = Lines
    self.MaxLineWidth = MaxWidth + 5

    --Set the scrolling size.
    self.ScrollingFrame.CanvasSize = UDim2.new(0, MaxWidth, 0, #Lines * self.TextHeight)
    self:UpdateAdornText()
end

--[[
Sets up the window to display logs.
--]]
function ScrollingTextWindow:DisplayLogs(Logs, Inverted)
    --Remove the refresh button.
    if self.RefreshButton then
        self.RefreshButton:Destroy()
    end
    local CurrentMessages, LastSearchTerm, MaxWidth = nil, "", 0

    --[[
    Returns if a log entry is in the current search.
    --]]
    local function PassesSearch(Message, SearchTerm)
        local Text = Message
        if type(Message) == "table" then
            Text = Message.Text
        end
        return string.find(string.lower(Text), string.lower(SearchTerm)) ~= nil
    end

    --[[
    Adds a message to store.
    --]]
    local function AddMessage(Message)
        if not PassesSearch(Message, LastSearchTerm) then return end

        --Split the lines.
        local Messages = {}
        if type(Message) == "string" then
            Message = {Text = Message}
        end
        for _, SubLine in string.split(Message.Text or "", "\n") do
            local LineData = {}
            for Key, Value in Message do
                LineData[Key] = Value
            end
            LineData.Text = SubLine
            table.insert(Messages, LineData)
        end

        --Update the max line width.
        for _, Line in Messages do
            local Text = Line.Text
            local Font = Line.Font or Enum.Font.SourceSans
            local LineLength = self.TextService:GetTextSize(Text, self.TextHeight, Font, Vector2.new(math.huge, self.TextHeight)).X
            MaxWidth = math.max(MaxWidth, LineLength)
        end
        self.MaxLineWidth = MaxWidth + 5

        --Add the messages.
        for _, Message in Messages do
            table.insert(CurrentMessages, Inverted and #CurrentMessages + 1 or 1, Message)
        end
    end

    --Set the UpdateText function.
    self.UpdateText = function()
        --Invalidate the current messages if the search term changed.
        local SearchTerm = self.SearchBar and self.SearchBar.Text or ""
        if SearchTerm ~= LastSearchTerm then
            CurrentMessages = nil
        end
        LastSearchTerm = SearchTerm

        --Build the current messages.
        if CurrentMessages == nil then
            CurrentMessages = {}
            MaxWidth = 0
            local LogEntries = Logs:GetLogs()
            for i = #LogEntries, 1, -1 do
                AddMessage(LogEntries[i])
            end
            self.Lines = CurrentMessages
        end

        --Set the scrolling size.
        self.ScrollingFrame.CanvasSize = UDim2.new(0, MaxWidth, 0, #CurrentMessages * self.TextHeight)
        self:UpdateAdornText()
    end

    --Connect logs being added.
    self.LogAddedConnection = Logs.LogAdded:Connect(function(LogEntry)
        AddMessage(LogEntry)
        self:UpdateText()
    end)
end

--[[
Callback for the window closing.
--]]
function ScrollingTextWindow:OnClose()
    self:TweenOut(Enum.NormalId.Left, function()
        self:Destroy()
        self.ScreenGui:Destroy()
        if self.LogAddedConnection then
            self.LogAddedConnection:Disconnect()
            self.LogAddedConnection = nil
        end
    end)
end

--[[
Callback for the window refreshing.
--]]
function ScrollingTextWindow:OnRefresh()
    self:UpdateText(true)
end



return ScrollingTextWindow