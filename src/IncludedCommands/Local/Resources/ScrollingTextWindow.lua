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
function ScrollingTextWindow:__new(DontCreateSearch)
    self:InitializeSuper()

    self.CurrentTextLabels = {}
    self.TextHeight = self.Camera.ViewportSize.Y * 0.5 * 0.045

    --Create the scrolling frame.
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Parent = self.ContentsAdorn
    self.ScrollingFrame = ScrollingFrame

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

    --Move the window off-screen.
    local CameraViewport = self.Camera.ViewportSize
    self.WindowFrame.Position = UDim2.new(0,CameraViewport.Y * -0.4,0,CameraViewport.Y * 0.2)

    --Update the window and show the window.
    self.WindowFrame.Parent = ScreenGui
    self:OnRefresh()
    self.WindowFrame:TweenPosition(UDim2.new(0,50,0,CameraViewport.Y * 0.2),"Out","Back",0.5,false)
end

--[[
Returns the lines to display.
--]]
function ScrollingTextWindow:GetTextLines(SearchTerm,ForceRefresh)
    return {}
end

--[[
Updates the text.
--]]
function ScrollingTextWindow:UpdateText(ForceRefresh)
    --Get the lines.
    local BaseLines = self:GetTextLines(self.SearchBar and self.SearchBar.Text or "",ForceRefresh or false)

    --Split the lines.
    local Lines = {}
    for _,Line in pairs(BaseLines) do
        if type(Line) == "string" then
            Line = {Text=Line}
        end
        for _,SubLine in pairs(string.split(Line.Text or "","\n")) do
            local LineData = {}
            for Key,Value in pairs(Line) do
                LineData[Key] = Value
            end
            LineData.Text = SubLine
            table.insert(Lines,LineData)
        end
    end

    --Create the list frames.
    local MaxWidth = 0
    for i = 1,#Lines do
        --Determine the font and width.
        local Line = Lines[i]
        local Text = Line.Text or ""
        local Font = Line.Font or "SourceSans"
        local LineLength = self.TextService:GetTextSize(Text,self.TextHeight,Font,Vector2.new(math.huge,self.TextHeight)).X
        MaxWidth = math.max(MaxWidth,LineLength)

        --Create the text label.
        if not self.CurrentTextLabels[i] then
            local TextLabel = Instance.new("TextBox")
            TextLabel.Position = UDim2.new(0,0,0,(i - 1) * self.TextHeight)
            TextLabel.BackgroundTransparency = 1
            TextLabel.ClearTextOnFocus = false
            TextLabel.TextEditable = false
            TextLabel.TextSize = self.TextHeight
            TextLabel.Font = "SourceSans"
            TextLabel.TextColor3 = Color3.new(1,1,1)
            TextLabel.TextStrokeColor3 = Color3.new(0,0,0)
            TextLabel.TextStrokeTransparency = 0
            TextLabel.TextXAlignment = "Left"
            TextLabel.Parent = self.ScrollingFrame
            self.CurrentTextLabels[i] = TextLabel
        end

        --Update the text label.
        local TextLabel = self.CurrentTextLabels[i]
        TextLabel.Font = Font
        TextLabel.Text = Text
        TextLabel.TextColor3 = Line.TextColor3 or Color3.new(1,1,1)
        TextLabel.Size = UDim2.new(0,LineLength,0,self.TextHeight)
    end

    --Remove the unneeded lines.
    for i = #self.CurrentTextLabels,#Lines + 1,-1 do
        self.CurrentTextLabels[i]:Destroy()
        table.remove(self.CurrentTextLabels,i)
    end

    --Set the scrolling size.
    self.ScrollingFrame.CanvasSize = UDim2.new(0,MaxWidth,0,#Lines * self.TextHeight)
end


--[[
Callback for the window closing.
--]]
function ScrollingTextWindow:OnClose()
    self.WindowFrame:TweenPosition(UDim2.new(0,-self.WindowFrame.AbsoluteSize.X - 50,0,self.WindowFrame.AbsolutePosition.Y),"In","Back",0.5,false,function()
        self:Destroy()
        self.ScreenGui:Destroy()
    end)
end

--[[
Callback for the window refreshing.
--]]
function ScrollingTextWindow:OnRefresh()
    self:UpdateText(true)
end



return ScrollingTextWindow