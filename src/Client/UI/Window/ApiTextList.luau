--Standard scrolling text list implementation.
--!strict

local TextService = game:GetService("TextService")

local NexusVirtualList = require(script.Parent.Parent.Parent:WaitForChild("NexusVirtualList"))
local CreateScrollingTextEntryCreator = require(script.Parent:WaitForChild("CreateScrollingTextEntryCreator"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

local ApiTextList = {}
ApiTextList.__index = ApiTextList

export type ApiTextList = {
    TextSize: number,
    MaxLineWidth: number,
    CurrentLines: {{[string]: any}},
    CurrentSearchTerm: string,
    Filter: ((SearchTerm: string, Lines: {{[string]: any}}) -> ({{[string]: any}}))?,
    Instances: {
        AdornFrame: Frame,
        ScrollingFrame: ScrollingFrame,
        SearchBar: TextBox?,
        VirtualList: any, --NexusVirtualList is not in the correct place for the client.
    },
    EventConnections: {any},
} & typeof(setmetatable({}, ApiTextList))



--[[
Creats an API text list.
--]]
function ApiTextList.new(Parent: Instance, TextSize: number, TextType: ("TextLabel" | "TextBox")?): ApiTextList
    --Create the frames.
    local AdornFrame = Instance.new("Frame")
    AdornFrame.BackgroundTransparency = 1
    AdornFrame.Size = UDim2.new(1, 5, 1, 0)
    AdornFrame.Parent = Parent

    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Size = UDim2.new(1, -10, 1, 0)
    ScrollingFrame.ScrollBarThickness = math.min(math.ceil(0.8 * TextSize), 10)
    ScrollingFrame.Parent = AdornFrame

    local VirtualList = NexusVirtualList.CreateVirtualScrollList(ScrollingFrame, CreateScrollingTextEntryCreator(TextSize, TextType or "TextBox"))

    --Create and return the object.
    return setmetatable({
        TextSize = TextSize,
        MaxLineWidth = 0,
        CurrentLines = {},
        CurrentSearchTerm = "",
        Instances = {
            AdornFrame = AdornFrame,
            ScrollingFrame = ScrollingFrame,
            VirtualList = VirtualList,
        },
        EventConnections = {},
    }, ApiTextList) :: ApiTextList
end

--[[
Enables searching in the text list.
--]]
function ApiTextList.EnableSearching(self: ApiTextList, Filter: ((SearchTerm: string, Lines: {{[string]: any}}) -> ({{[string]: any}}))?): ()
    --Resize the scrolling frame.
    local TextSize = self.TextSize
    local ScrollingFrame = self.Instances.ScrollingFrame
    ScrollingFrame.Size = UDim2.new(1, -10, 1, -10 - (1.3 * TextSize))
    ScrollingFrame.Position = UDim2.new(0, 5, 0, 5 + (1.3 * TextSize))

    --Create the search box.
    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Size = UDim2.new(0, TextSize, 0, TextSize)
    SearchIcon.Position = UDim2.new(0, 0.25 * TextSize, 0, 0.25 * TextSize)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = "rbxasset://textures/StudioToolbox/Search.png"
    SearchIcon.Parent = self.Instances.AdornFrame

    local SearchBar = Instance.new("TextBox")
    SearchBar.BackgroundTransparency = 0.5
    SearchBar.Size = UDim2.new(1, -2 * TextSize, 0, 1.2 * TextSize)
    SearchBar.Position = UDim2.new(0, 1.5 * TextSize, 0, 0.15 * TextSize)
    SearchBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SearchBar.BorderSizePixel = 0
    SearchBar.Text = ""
    SearchBar.Font = Enum.Font.SourceSans
    SearchBar.TextSize = TextSize
    SearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBar.ClearTextOnFocus = false
    SearchBar.ClipsDescendants = true
    SearchBar.TextXAlignment = Enum.TextXAlignment.Left
    SearchBar.Parent = self.Instances.AdornFrame
    self.Instances.SearchBar = SearchBar

    --Store the filter.
    self.Filter = Filter or function(SearchTerm, Lines)
        --Return the original lines if the search term is empty.
        if SearchTerm == "" then
            return Lines
        end

        --Filter the lines.
        local NewLines = {}
        for _, Line in Lines do
            local Text = Line.Text
            if not Text then continue end
            if not string.find(string.lower(Text), string.lower(SearchTerm)) then continue end
            table.insert(NewLines, Line)
        end
        return NewLines
    end

    SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
        self.CurrentSearchTerm = SearchBar.Text
        self:UpdateDisplayedLines()
    end)
end

--[[
Moves the API text list.
--]]
function ApiTextList.Move(self: ApiTextList, Size: UDim2?, Position: UDim2?, AnchorPoint: Vector2?): ()
    local AdornFrame = self.Instances.AdornFrame
    AdornFrame.Size = Size or AdornFrame.Size
    AdornFrame.Position = Position or AdornFrame.Position
    AdornFrame.AnchorPoint = AnchorPoint or AdornFrame.AnchorPoint
end

--[[
Updates the displayed lines.
--]]
function ApiTextList.UpdateDisplayedLines(self: ApiTextList): ()
    --Filter the lines.
    local Lines = self.CurrentLines
    if self.Filter then
        Lines = self.Filter(self.CurrentSearchTerm, Lines)
    end

    --Split the lines.
    local SplitLines = {}
    for _, Line in Lines do
        for _, SubLine in string.split(Line.Text or "", "\n") do
            local LineData = {}
            for Key, Value in Line do
                LineData[Key] = Value
            end
            LineData.Text = SubLine
            table.insert(SplitLines, LineData)
        end
    end

    --Show the lines.
    self.Instances.VirtualList:SetData(SplitLines)
end

--[[
Adds lines to the window.
--]]
function ApiTextList.AddLines(self: ApiTextList, Lines: {string | {[string]: any}}, Order: ("NewestFirst" | "OldestFirst")?): ()
    --Convert the lines.
    local NewLines = {} :: {{[string]: any}}
    for _, Line in Lines do
        --Convert the line.
        if typeof(Line) == "string" then
            Line = {
                Text = Line,
            }
        end

        --Add the line.
        local CurrentLine = Line :: {[string]: any}
        table.insert(NewLines, CurrentLine)
        if Order == "NewestFirst" then
            table.insert(self.CurrentLines, 1, CurrentLine)
        else
            table.insert(self.CurrentLines, CurrentLine)
        end
    end

    --Update the max width of the lines.
    for _, Line in NewLines do
        local Text = Line.Text
        local Font = Line.Font or Enum.Font.SourceSans
        local LineLength = TextService:GetTextSize(Text, self.TextSize, Font, Vector2.new(math.huge, self.TextSize)).X
        self.MaxLineWidth = math.max(self.MaxLineWidth, LineLength)
    end

    --Set the lines.
    self.Instances.VirtualList:SetScrollWidth(UDim.new(0, self.MaxLineWidth + 5))
    self:UpdateDisplayedLines()
end

--[[
Sets the lines of the window.
--]]
function ApiTextList.SetLines(self: ApiTextList, Lines: {string | {[string]: any}}): ()
    self.CurrentLines = {}
    self.MaxLineWidth = 0
    self:AddLines(Lines)
end

--[[
Displays logs and automatically updates when new entries are added.
--]]
function ApiTextList.DisplayLogs(self: ApiTextList, Logs: Types.Logs, Order: ("NewestFirst" | "OldestFirst")?): ()
    --Add the initial messages.
    local LogEntries = Logs:GetLogs()
    if Order == "NewestFirst" then
        local NewLogs = {}
        for i = #LogEntries, 1, -1 do
            table.insert(NewLogs, LogEntries[i])
        end
        LogEntries = NewLogs
    end
    self:AddLines(LogEntries, Order)

    --Connect logs being added.
    table.insert(self.EventConnections, Logs.LogAdded:Connect(function(LogEntry)
        self:AddLines({LogEntry}, Order)
    end))
end

--[[
Destroys the API text list.
--]]
function ApiTextList.Destroy(self: ApiTextList): ()
    for _, EventConnection in self.EventConnections do
        EventConnection:Disconnect()
    end
    self.Instances.AdornFrame:Destroy()
    self.Instances.VirtualList:Destroy()
end



return ApiTextList