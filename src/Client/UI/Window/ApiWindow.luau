--Standard window used with the Window API.
--!strict

local MINIMUM_TEXT_SIZE = 12

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local NexusButton = require(script.Parent.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusButton"))
local ApiTextList = require(script.Parent:WaitForChild("ApiTextList"))

local ButtonFactory = NexusButton.ButtonFactory
local TextButtonFactory = NexusButton.TextButtonFactory
local ThemedFrame = NexusButton.ThemedFrame

local RefreshFactory = ButtonFactory.CreateDefault(Color3.fromRGB(0, 200, 0))
local CloseFactory = TextButtonFactory.CreateDefault(Color3.fromRGB(200, 0, 0))
CloseFactory:SetTextDefault("Text", "X")
CloseFactory:SetTextDefault("Font", Enum.Font.SciFi)
CloseFactory:SetTextDefault("TextStrokeTransparency", 1)

local ApiWindow = {}
ApiWindow.__index = ApiWindow

export type ApiWindow = {
    IsOpen: boolean,
    InitialViewportSize: Vector2,
    InitialHeight: number,
    InitialWidth: number,
    TextHeight: number,
    StartSide: Enum.NormalId,
    ContentsAdorn: Frame,
    Instances: {
        ScreenGui: ScreenGui,
        WindowFrame: Frame,
        TopBarAdorn: TextButton,
        BackgroundAdorn: Frame,
        ContentsAdorn: Frame,
        TitleText: TextLabel,
        Background: any, --ThemedFrame is not in the correct place for the client.
        TopBarBackground: any, --ThemedFrame is not in the correct place for the client.
        ResizeCorner: any?, --ThemedFrame is not in the correct place for the client.
        RefreshButton: any?, --NexusButton is not in the correct place for the client.
        CloseButton: any?, --NexusButton is not in the correct place for the client.
        TextLists: {ApiTextList.ApiTextList},
    },
    EventConnections: {RBXScriptConnection},
} & typeof(setmetatable({}, ApiWindow))



--[[
Creates an API Window.
--]]
function ApiWindow.new(): ApiWindow
    --Create the base window.
    local Camera = Workspace.CurrentCamera
    local WindowHeight = math.max(math.ceil(0.5 * Camera.ViewportSize.Y), 5 * MINIMUM_TEXT_SIZE)
    local TopBarHeightPixel = math.ceil(WindowHeight * 0.1)
    local CornerSizePixel = math.floor(TopBarHeightPixel * 0.4)

    local WindowScreenGui = Instance.new("ScreenGui")
    WindowScreenGui.Name = "NexusAdminWindow"
    WindowScreenGui.ResetOnSpawn = false
    WindowScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local WindowFrame = Instance.new("Frame")
    WindowFrame.BackgroundTransparency = 1
    WindowFrame.Parent = WindowScreenGui

    local TopBarAdorn = Instance.new("TextButton")
    TopBarAdorn.Size = UDim2.new(1, 0, 0, TopBarHeightPixel)
    TopBarAdorn.BackgroundTransparency = 1
    TopBarAdorn.Text = ""
    TopBarAdorn.Parent = WindowFrame

    local BackgroundAdorn = Instance.new("Frame")
    BackgroundAdorn.Position = UDim2.new(0, 0, 0, TopBarHeightPixel)
    BackgroundAdorn.Size = UDim2.new(1, 0, 1, -TopBarHeightPixel)
    BackgroundAdorn.BackgroundTransparency = 1
    BackgroundAdorn.Parent = WindowFrame

    local ContentsAdorn = Instance.new("Frame")
    ContentsAdorn.Position = UDim2.new(0,0,0,TopBarHeightPixel)
    ContentsAdorn.Size = UDim2.new(1, 0, 1, -TopBarHeightPixel - CornerSizePixel)
    ContentsAdorn.BackgroundTransparency = 1
    ContentsAdorn.Parent = WindowFrame

    --Create the backgrounds.
    local Background = ThemedFrame.new()
    Background.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Background.BackgroundTransparency = 0.75 * GuiService.PreferredTransparency
    Background.Size = UDim2.new(1,0,1,0)
    Background.Theme = "CutBottomRightCorner"
    Background.Parent = BackgroundAdorn

    BackgroundAdorn:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        Background.SliceScaleMultiplier = 1.5 * (TopBarAdorn.AbsoluteSize.Y / BackgroundAdorn.AbsoluteSize.Y)
    end)

    local TopBarBackground = ThemedFrame.new()
    TopBarBackground.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    TopBarBackground.BackgroundTransparency = 0.5 * GuiService.PreferredTransparency
    TopBarBackground.Size = UDim2.new(1,0,1,0)
    TopBarBackground.Theme = "CutTopLeftCorner"
    TopBarBackground.SliceScaleMultiplier = 1.5
    TopBarBackground.Parent = TopBarAdorn

    --Create the top bar text.
    local TitleText = Instance.new("TextLabel")
    TitleText.BackgroundTransparency = 1
    TitleText.Size = UDim2.new(1, -(TopBarHeightPixel * 0.4), 1, -2 * (TopBarHeightPixel * 0.1))
    TitleText.Position = UDim2.new(0, 4 * (TopBarHeightPixel * 0.1), 0, TopBarHeightPixel * 0.1)
    TitleText.ClipsDescendants = true
    TitleText.Text = "Window"
    TitleText.Font = Enum.Font.SciFi
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TitleText.TextStrokeTransparency = 0
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.TextSize = TopBarHeightPixel * (36 / 44)
    TitleText.ZIndex = 3
    TitleText.Parent = TopBarAdorn

    --Create the object.
    local self = setmetatable({
        IsOpen = false,
        InitialViewportSize = Camera.ViewportSize,
        InitialHeight = WindowHeight,
        InitialWidth = math.ceil(0.375 * Camera.ViewportSize.Y),
        TextHeight = math.max(MINIMUM_TEXT_SIZE, math.ceil(Camera.ViewportSize.Y * 0.5 * 0.045)),
        StartSide = Enum.NormalId.Left,
        ContentsAdorn = ContentsAdorn,
        Instances = {
            ScreenGui = WindowScreenGui,
            WindowFrame = WindowFrame,
            TopBarAdorn = TopBarAdorn,
            BackgroundAdorn = BackgroundAdorn,
            ContentsAdorn = ContentsAdorn,
            TitleText = TitleText,
            Background = Background,
            TopBarBackground = TopBarBackground,
            TextLists = {},
        },
        EventConnections = {},
    }, ApiWindow) :: ApiWindow

    --Connect the drag events.
    local MouseDown = false
    local LastPosition = nil
    table.insert(self.EventConnections, TopBarAdorn.MouseButton1Down:Connect(function()
        MouseDown = true
        LastPosition = UserInputService:GetMouseLocation()
    end))

    table.insert(self.EventConnections, UserInputService.InputChanged:Connect(function(Input)
        if not LastPosition then return end
        if not MouseDown then return end
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch then return end

        local MousePosition = UserInputService:GetMouseLocation()
        local Delta = MousePosition - LastPosition
        LastPosition =  MousePosition
        WindowFrame.Position = UDim2.new(0, WindowFrame.Position.X.Offset + Delta.X, 0, WindowFrame.Position.Y.Offset + Delta.Y)
    end))

    table.insert(self.EventConnections, UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end
        
        MouseDown = false
        LastPosition = nil
    end))

    --Connect the transparency changing.
    table.insert(self.EventConnections, GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
        Background.BackgroundTransparency = 0.75 * GuiService.PreferredTransparency
        TopBarBackground.BackgroundTransparency = 0.5 * GuiService.PreferredTransparency
    end))

    --Return the object.
    return self
end

--[[
Updates the top bar.
--]]
function ApiWindow.UpdateTopBar(self: ApiWindow): ()
    --Move the refresh button.
    local TopBarHeightPixel = self.Instances.TopBarAdorn.Size.Y.Offset
    if self.Instances.RefreshButton then
        if self.Instances.CloseButton then
            self.Instances.RefreshButton.Position = UDim2.new(1, -TopBarHeightPixel * 1.8, 0, TopBarHeightPixel * 0.075)
        else
            self.Instances.RefreshButton.Position = UDim2.new(1, -TopBarHeightPixel * 0.9, 0, TopBarHeightPixel * 0.075)
        end
    end

    --Update the title text width.
    if self.Instances.RefreshButton and self.Instances.CloseButton then
        self.Instances.TitleText.Size = UDim2.new(1, -(TopBarHeightPixel * 2.4), 1, -2 * (TopBarHeightPixel * 0.1))
    elseif self.Instances.RefreshButton or self.Instances.CloseButton then
        self.Instances.TitleText.Size = UDim2.new(1, -(TopBarHeightPixel * 1.4), 1, -2 * (TopBarHeightPixel * 0.1))
    else
        self.Instances.TitleText.Size = UDim2.new(1, -(TopBarHeightPixel * 0.4), 1, -2 * (TopBarHeightPixel * 0.1))
    end
end

--[[
Allows the window to be resized.
--]]
function ApiWindow.EnableResizing(self: ApiWindow, MinWidth: number?, MinHeight: number?, MaxWidth: number?, MaxHeight: number?): ()
    --Create the resize corner.
    local WindowHeight = self.InitialViewportSize.Y * 0.5
    local TopBarHeightPixel = WindowHeight * 0.1
    local CornerSizePixel = TopBarHeightPixel * 0.4
    local ResizeCornerSizePixel = CornerSizePixel * 1.5

    MinWidth = MinWidth or WindowHeight * 0.6
    MinHeight = MinHeight or TopBarHeightPixel * 2
    MaxWidth = MaxWidth or math.huge
    MaxHeight = MaxHeight or math.huge

    local ResizeCornerAdorn = Instance.new("TextButton")
    ResizeCornerAdorn.Size = UDim2.new(0, ResizeCornerSizePixel, 0, ResizeCornerSizePixel)
    ResizeCornerAdorn.Position = UDim2.new(1, -ResizeCornerSizePixel, 1, -ResizeCornerSizePixel)
    ResizeCornerAdorn.BackgroundTransparency = 1
    ResizeCornerAdorn.Text = ""
    ResizeCornerAdorn.Parent = self.Instances.WindowFrame

    local ResizeCorner = ThemedFrame.new()
    ResizeCorner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ResizeCorner.BackgroundTransparency = 0.5 * GuiService.PreferredTransparency
    ResizeCorner.Size = UDim2.new(1, 0, 1, 0)
    ResizeCorner.Theme = "CutBottomRightCorner"
    ResizeCorner.SliceScaleMultiplier = 2
    ResizeCorner.Parent = ResizeCornerAdorn
    self.Instances.ResizeCorner = ResizeCorner

    self.Instances.ContentsAdorn.Size = UDim2.new(1, 0, 1, -TopBarHeightPixel - ResizeCornerSizePixel)

    --Connect the events.
    local MouseDown = false
    local LastPosition = nil
    local IntendedSizeX: number?, IntendedSizeY: number? = nil, nil
    table.insert(self.EventConnections, ResizeCornerAdorn.MouseButton1Down:Connect(function()
        MouseDown = true
        LastPosition = UserInputService:GetMouseLocation()
        IntendedSizeX, IntendedSizeY = self.Instances.WindowFrame.Size.X.Offset, self.Instances.WindowFrame.Size.Y.Offset
    end))

    table.insert(self.EventConnections, UserInputService.InputChanged:Connect(function(Input)
        if not LastPosition then return end
        if not MouseDown then return end
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch then return end

        local MousePosition = UserInputService:GetMouseLocation()
        local Delta = MousePosition - LastPosition
        LastPosition =  MousePosition
        IntendedSizeX, IntendedSizeY = IntendedSizeX + Delta.X, IntendedSizeY + Delta.Y
        self.Instances.WindowFrame.Size = UDim2.new(0,math.clamp(IntendedSizeX :: number, MinWidth :: number, MaxWidth :: number),0,math.clamp(IntendedSizeY + Delta.Y, MinHeight :: number, MaxHeight :: number))
    end))

    table.insert(self.EventConnections, UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end
        MouseDown = false
        LastPosition = nil
        IntendedSizeX, IntendedSizeY = nil, nil
    end))

    table.insert(self.EventConnections, GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
        ResizeCorner.BackgroundTransparency = 0.5 * GuiService.PreferredTransparency
    end))
end

--[[
Enables the close button.
--]]
function ApiWindow.EnableClosing(self: ApiWindow, OnClose: (() -> ())?): ()
    --Create the button.
    local TopBarHeightPixel = self.Instances.TopBarAdorn.Size.Y.Offset
    local CloseButton = CloseFactory:Create()
    CloseButton.Size = UDim2.new(0, TopBarHeightPixel * 0.8, 0, TopBarHeightPixel * 0.7)
    CloseButton.Position = UDim2.new(1, -TopBarHeightPixel * 0.9, 0, TopBarHeightPixel * 0.075)
    CloseButton.Parent = self.Instances.TopBarAdorn
    self.Instances.CloseButton = CloseButton

    --Connect the button.
    local Closed = false
    table.insert(self.EventConnections, CloseButton.MouseButton1Down:Connect(function()
        if Closed then return end
        Closed = true
        if OnClose then
            OnClose()
        end
        self:Close()
    end))

    --Update the top bar.
    self:UpdateTopBar()
end

--[[
Enables the refresh button.
--]]
function ApiWindow.EnableRefreshing(self: ApiWindow, OnRefresh: () -> ()): ()
    --Create the button.
    local TopBarHeightPixel = self.Instances.TopBarAdorn.Size.Y.Offset
    local RefreshButton = RefreshFactory:Create()
    RefreshButton.Size = UDim2.new(0,TopBarHeightPixel * 0.8,0,TopBarHeightPixel * 0.7)
    RefreshButton.Parent = self.Instances.TopBarAdorn
    self.Instances.RefreshButton = RefreshButton

    local RefreshIcon = Instance.new("ImageLabel")
    RefreshIcon.BackgroundTransparency = 1
    RefreshIcon.Size = UDim2.new(0.8, 0, 0.8, 0)
    RefreshIcon.SizeConstraint = Enum.SizeConstraint.RelativeYY
    RefreshIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    RefreshIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    RefreshIcon.Image = "rbxassetid://86084882582277"
    RefreshIcon.ZIndex = 4
    RefreshIcon.Parent = RefreshButton:GetAdornFrame()

    --Connect the button.
    local DB = false
    table.insert(self.EventConnections, RefreshButton.MouseButton1Down:Connect(function()
        if DB then return end
        DB = true
        OnRefresh()
        task.wait()
        DB = false
    end))

    --Update the top bar.
    self:UpdateTopBar()
end

--[[
Sets the title of the window.
--]]
function ApiWindow.SetTitle(self: ApiWindow, Name: string): ()
    self.Instances.TitleText.Text = Name
    self.Instances.ScreenGui.Name = `NexusAdminWindow_{Name}`
end

--[[
Sets the display order of the window.
--]]
function ApiWindow.SetDisplayOrder(self: ApiWindow, DisplayOrder: number): ()
    self.Instances.ScreenGui.DisplayOrder = DisplayOrder
end

--[[
Sets the relative size with the X relative to the Y.
--]]
function ApiWindow.SetRelativeSize(self: ApiWindow, RelativeX: number, RelativeY: number): ()
    self.InitialWidth = (RelativeX * self.InitialViewportSize.Y)
    self.InitialHeight = (RelativeY * self.InitialViewportSize.Y)
end

--[[
Adds a text list to the menu.
--]]
function ApiWindow.AddTextList(self: ApiWindow, TextType: ("TextLabel" | "TextBox")?, RichText: boolean?): ApiTextList.ApiTextList
    local TextList = ApiTextList.new(self.ContentsAdorn, self.TextHeight, TextType, RichText or false)
    table.insert(ApiTextList, TextList)
    return TextList
end

--[[
Shows the window.
--]]
function ApiWindow.Show(self: ApiWindow, InitialPosition: UDim2?, InitialAnchorPoint: Vector2?, StartSide: Enum.NormalId?): ()
    if self.IsOpen then return end
    self.IsOpen = true
    
    --Determine the target position.
    local TargetPosition = Vector2.new(0.1 * self.InitialViewportSize.X, 0.2 * self.InitialViewportSize.Y)
    if InitialPosition then
        TargetPosition = Vector2.new(InitialPosition.X.Offset + (InitialPosition.X.Scale * self.InitialViewportSize.X), InitialPosition.Y.Offset + (InitialPosition.Y.Scale * self.InitialViewportSize.Y))
    end
    if InitialAnchorPoint then
        TargetPosition += Vector2.new(-InitialAnchorPoint.X * self.InitialWidth, -InitialAnchorPoint.Y * self.InitialHeight)
    end

    --Set the window size and position.
    self.StartSide = StartSide or self.StartSide
    self.Instances.WindowFrame.Size = UDim2.new(0, self.InitialWidth, 0, self.InitialHeight)
    if self.StartSide == Enum.NormalId.Left then
        self.Instances.WindowFrame.Position = UDim2.new(0, -self.InitialWidth, 0, TargetPosition.Y)
    elseif self.StartSide == Enum.NormalId.Right then
        self.Instances.WindowFrame.Position = UDim2.new(1, 0, 0, TargetPosition.Y)
    elseif self.StartSide == Enum.NormalId.Top then
        self.Instances.WindowFrame.Position = UDim2.new(0, TargetPosition.X, 0, -self.InitialHeight)
    elseif self.StartSide == Enum.NormalId.Bottom then
        self.Instances.WindowFrame.Position = UDim2.new(0, TargetPosition.X, 1, 0)
    end

    --Move the window.
    local FinalPosition = UDim2.new(0, TargetPosition.X, 0, TargetPosition.Y)
    if GuiService.ReducedMotionEnabled then
        self.Instances.WindowFrame.Position = FinalPosition
    else
        TweenService:Create(self.Instances.WindowFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = FinalPosition,
        }):Play()
    end
end

--[[
Closes the window.
--]]
function ApiWindow.Close(self: ApiWindow): ()
    if not self.IsOpen then return end
    self.IsOpen = false

    --Determine the target position.
    local FinalPosition = UDim2.new()
    local CurrentSize, CurrentPosition = self.Instances.WindowFrame.AbsoluteSize, self.Instances.WindowFrame.AbsolutePosition
    if self.StartSide == Enum.NormalId.Left then
        FinalPosition = UDim2.new(0, -CurrentSize.X, 0, CurrentPosition.Y)
    elseif self.StartSide == Enum.NormalId.Right then
        FinalPosition = UDim2.new(1, 0, 0, CurrentPosition.Y)
    elseif self.StartSide == Enum.NormalId.Top then
        FinalPosition = UDim2.new(0, CurrentPosition.X, 0, -CurrentSize.Y)
    elseif self.StartSide == Enum.NormalId.Bottom then
        FinalPosition = UDim2.new(0, CurrentPosition.X, 1, 0)
    end

    --Move the window.
    if GuiService.ReducedMotionEnabled then
        self.Instances.WindowFrame.Position = FinalPosition
    else
        TweenService:Create(self.Instances.WindowFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = FinalPosition,
        }):Play()
    end

    --Destroy the window.
    task.delay(0.5, function()
        self:Destroy()
    end)
end

--[[
Destroys the API Window.
--]]
function ApiWindow.Destroy(self: ApiWindow): ()
    --Disconnect the events.
    for _, EventConnection in self.EventConnections do
        EventConnection:Disconnect()
    end

    --Destroy the instances.
    self.Instances.ScreenGui:Destroy()
    self.Instances.Background:Destroy()
    self.Instances.TopBarBackground:Destroy()
    if self.Instances.ResizeCorner then
        self.Instances.ResizeCorner:Destroy()
    end
    if self.Instances.RefreshButton then
        self.Instances.RefreshButton:Destroy()
    end
    if self.Instances.CloseButton then
        self.Instances.CloseButton:Destroy()
    end
    for _, TextList in self.Instances.TextLists do
        TextList:Destroy()
    end
end



return ApiWindow