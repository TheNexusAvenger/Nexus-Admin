--[[
TheNexusAvenger

Class representing a window.
--]]

local REFRESH_ICON = "rbxasset://textures/StudioToolbox/AssetConfig/restore@3x.png"



local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local NexusInstance = require(script.Parent.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusInstance"))

local NexusButton = script.Parent.Parent.Parent:WaitForChild("NexusButton")
local ButtonFactory = require(NexusButton:WaitForChild("Factory"):WaitForChild("ButtonFactory"))
local TextButtonFactory = require(NexusButton:WaitForChild("Factory"):WaitForChild("TextButtonFactory"))
local ThemedFrame = require(NexusButton:WaitForChild("ThemedFrame"))

local RefreshFactory = ButtonFactory.CreateDefault(Color3.new(0,200/255,0))
local CloseFactory = TextButtonFactory.CreateDefault(Color3.new(200/255,0,0))
CloseFactory:SetTextDefault("Text","X")
CloseFactory:SetTextDefault("Font",Enum.Font.SciFi)
CloseFactory:SetTextDefault("TextStrokeTransparency",1)

local Window = NexusInstance:Extend()
Window:SetClassName("Window")
Window.Camera = game:GetService("Workspace").CurrentCamera
Window.UserInputService = game:GetService("UserInputService")



--[[
Creates the window.
--]]
function Window:__new()
    self:InitializeSuper()
    local DB = true

    --Calculate the heights.
    local ViewportSize = self.Camera.ViewportSize
    local WindowHeight = ViewportSize.Y * 0.5
    local TopBarHeightPixel = WindowHeight * 0.1
    local CornerSizePixel = TopBarHeightPixel * 0.4

    --Create the adorn frames.
    local WindowFrame = Instance.new("Frame")
    WindowFrame.BackgroundTransparency = 1
    WindowFrame.Size = UDim2.new(0,ViewportSize.Y * 0.375,0,WindowHeight)
    self.WindowFrame = WindowFrame

    local TopBarAdorn = Instance.new("TextButton")
    TopBarAdorn.Size = UDim2.new(1,0,0,TopBarHeightPixel)
    TopBarAdorn.BackgroundTransparency = 1
    TopBarAdorn.Text = ""
    TopBarAdorn.Parent = WindowFrame
    self.TopBarAdorn = TopBarAdorn

    local BackgroundAdorn = Instance.new("Frame")
    BackgroundAdorn.Position = UDim2.new(0,0,0,TopBarHeightPixel)
    BackgroundAdorn.Size = UDim2.new(1,0,1,-TopBarHeightPixel)
    BackgroundAdorn.BackgroundTransparency = 1
    BackgroundAdorn.Parent = WindowFrame
    self.BackgroundAdorn = BackgroundAdorn

    local ContentsAdorn = Instance.new("Frame")
    ContentsAdorn.Position = UDim2.new(0,0,0,TopBarHeightPixel)
    ContentsAdorn.Size = UDim2.new(1,0,1,-TopBarHeightPixel - CornerSizePixel)
    ContentsAdorn.BackgroundTransparency = 1
    ContentsAdorn.Parent = WindowFrame
    self.ContentsAdorn = ContentsAdorn

    --Create the backgrounds.
    local Background = ThemedFrame.new()
    Background.BackgroundColor3 = Color3.new(0,0,0)
    Background.BackgroundTransparency = 0.75 * GuiService.PreferredTransparency
    Background.Size = UDim2.new(1,0,1,0)
    Background.Theme = "CutBottomRightCorner"
    Background.Parent = BackgroundAdorn
    self.Background = Background

    BackgroundAdorn:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        Background.SliceScaleMultiplier = 1.5 * (TopBarAdorn.AbsoluteSize.Y / BackgroundAdorn.AbsoluteSize.Y)
    end)

    local TopBarBackground = ThemedFrame.new()
    TopBarBackground.BackgroundColor3 = Color3.new(0,170/255,1)
    TopBarBackground.BackgroundTransparency = 0.5 * GuiService.PreferredTransparency
    TopBarBackground.Size = UDim2.new(1,0,1,0)
    TopBarBackground.Theme = "CutTopLeftCorner"
    TopBarBackground.SliceScaleMultiplier = 1.5
    TopBarBackground.Parent = TopBarAdorn
    self.TopBarBackground = TopBarBackground

    --Create the top bar elements.
    local TitleText = Instance.new("TextLabel")
    TitleText.BackgroundTransparency = 1
    TitleText.Size = UDim2.new(1,-(TopBarHeightPixel * 0.4),1,-2 * (TopBarHeightPixel * 0.1))
    TitleText.Position = UDim2.new(0,4 * (TopBarHeightPixel * 0.1),0,TopBarHeightPixel * 0.1)
    TitleText.ClipsDescendants = true
    TitleText.Font = "SciFi"
    TitleText.TextColor3 = Color3.new(1,1,1)
    TitleText.TextStrokeColor3 = Color3.new(0,0,0)
    TitleText.TextStrokeTransparency = 0
    TitleText.TextXAlignment = "Left"
    TitleText.TextSize = TopBarHeightPixel * (36/44)
    TitleText.ZIndex = 3
    TitleText.Parent = TopBarAdorn

    --Connect the events.
    self.Events = {}
    local MouseDown = false
    local LastPosition
    table.insert(self.Events,TopBarAdorn.MouseButton1Down:Connect(function()
        MouseDown = true
        LastPosition = UserInputService:GetMouseLocation()
    end))

    table.insert(self.Events,self.UserInputService.InputChanged:Connect(function(Input)
        if LastPosition and MouseDown and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local MousePosition = UserInputService:GetMouseLocation()
            local Delta = MousePosition - LastPosition
            LastPosition =  MousePosition
            WindowFrame.Position = UDim2.new(0,WindowFrame.Position.X.Offset + Delta.X,0,WindowFrame.Position.Y.Offset + Delta.Y)
        end
    end))

    table.insert(self.Events,self.UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            MouseDown = false
            LastPosition = nil
        end
    end))

    table.insert(self.Events,self:GetPropertyChangedSignal("Title"):Connect(function()
        TitleText.Text = self.Title
    end))

    table.insert(self.Events,self:GetPropertyChangedSignal("OnRefresh"):Connect(function()
        if self.object.OnRefresh then
            --Create the button.
            local RefreshButton = RefreshFactory:Create()
            RefreshButton.Size = UDim2.new(0,TopBarHeightPixel * 0.8,0,TopBarHeightPixel * 0.7)
            if self.CloseButton then
                RefreshButton.Position = UDim2.new(1,-TopBarHeightPixel * 1.8,0,TopBarHeightPixel * 0.075)
                TitleText.Size = UDim2.new(1,-(TopBarHeightPixel * 1.4),1,-2 * (TopBarHeightPixel * 0.1))
            else
                RefreshButton.Position = UDim2.new(1,-TopBarHeightPixel * 0.9,0,TopBarHeightPixel * 0.075)
                TitleText.Size = UDim2.new(1,-(TopBarHeightPixel * 2.4),1,-2 * (TopBarHeightPixel * 0.1))
            end
            RefreshButton.Parent = TopBarAdorn
            self.RefreshButton = RefreshButton

            local RefreshIcon = Instance.new("ImageLabel")
            RefreshIcon.BackgroundTransparency = 1
            RefreshIcon.Size = UDim2.new(0.8,0,0.8,0)
            RefreshIcon.SizeConstraint = "RelativeYY"
            RefreshIcon.AnchorPoint = Vector2.new(0.5,0.5)
            RefreshIcon.Position = UDim2.new(0.5,0,0.5,0)
            RefreshIcon.Image = REFRESH_ICON
            RefreshIcon.ZIndex = 4
            RefreshIcon.Parent = RefreshButton:GetAdornFrame()

            --Connect the button.
            table.insert(self.Events,RefreshButton.MouseButton1Down:Connect(function()
                if DB == true then
                    DB = false
                    self.object:OnRefresh()
                    wait()
                    DB = true
                end
            end))
        end
    end))

    table.insert(self.Events,self:GetPropertyChangedSignal("OnClose"):Connect(function()
        if self.object.OnClose and not self.CloseButton then
            --Create the button.
            local CloseButton = CloseFactory:Create()
            CloseButton.Size = UDim2.new(0,TopBarHeightPixel * 0.8,0,TopBarHeightPixel * 0.7)
            CloseButton.Position = UDim2.new(1,-TopBarHeightPixel * 0.9,0,TopBarHeightPixel * 0.075)
            CloseButton.Parent = TopBarAdorn
            self.CloseButton = CloseButton

            --Connect the button.
            table.insert(self.Events,CloseButton.MouseButton1Down:Connect(function()
                if DB == true then
                    DB = false
                    self.object:OnClose()
                    wait()
                    DB = true
                end
            end))

            --Update the refresh button position.
            if self.RefreshButton then
                self.RefreshButton.Position = UDim2.new(1,-TopBarHeightPixel * 1.8,0,TopBarHeightPixel * 0.075)
                TitleText.Size = UDim2.new(1,-(TopBarHeightPixel * 2.4),1,-2 * (TopBarHeightPixel * 0.1))
            else
                TitleText.Size = UDim2.new(1,-(TopBarHeightPixel * 1.4),1,-2 * (TopBarHeightPixel * 0.1))
            end
        end
    end))

    table.insert(self.Events, GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
        Background.BackgroundTransparency = 0.75 * GuiService.PreferredTransparency
        TopBarBackground.BackgroundTransparency = 0.5 * GuiService.PreferredTransparency
    end))

    --Set the defaults.
    self.Title = "Window Title"
    self:GetPropertyChangedSignal("OnRefresh"):Fire()
    self:GetPropertyChangedSignal("OnClose"):Fire()
end

--[[
Moves the window to a position.
--]]
function Window:MoveTo(Side: Enum.NormalId?, PositionRelative: number?, OffsetRelative: number?): ()
    --Determine the fixed position.
    local IsTopOrBottom = (Side == Enum.NormalId.Top or Side == Enum.NormalId.Bottom)
    local GuiInsetCorner1, GuiInsetCorner2 = GuiService:GetGuiInset()
    local CameraViewport = self.Camera.ViewportSize - GuiInsetCorner1 - GuiInsetCorner2
    local FixedPosition = (IsTopOrBottom and CameraViewport.X or CameraViewport.Y) * (PositionRelative or 0.2)
    if OffsetRelative then
        FixedPosition += -OffsetRelative * (IsTopOrBottom and self.WindowFrame.AbsoluteSize.X or self.WindowFrame.AbsoluteSize.Y)
    end

    --Determine the start position.
    local Width = (IsTopOrBottom and self.WindowFrame.AbsoluteSize.Y or self.WindowFrame.AbsoluteSize.X)
    local StartPosition = 0
    if not Side or Side == Enum.NormalId.Left or Side == Enum.NormalId.Top then
        StartPosition = -1.1 * Width
    elseif Side == Enum.NormalId.Right or Side == Enum.NormalId.Bottom then
        StartPosition = (IsTopOrBottom and CameraViewport.Y or CameraViewport.X) + (0.1 * Width)
    end

    --Move the window.
    if IsTopOrBottom then
        self.WindowFrame.Position = UDim2.new(0, FixedPosition, 0, StartPosition)
    else
        self.WindowFrame.Position = UDim2.new(0, StartPosition, 0, FixedPosition)
    end
end

--[[
Tweens the window to a position.
--]]
function Window:TweenTo(Side: Enum.NormalId?, PositionRelative: number?, FinishCallback: (() -> ())?, EasingDirection: Enum.EasingDirection?): ()
    --Determine the fixed position.
    local IsTopOrBottom = (Side == Enum.NormalId.Top or Side == Enum.NormalId.Bottom)
    local FixedPosition = (IsTopOrBottom and self.WindowFrame.AbsolutePosition.X or self.WindowFrame.AbsolutePosition.Y)

    --Determine the end position.
    local GuiInsetCorner1, GuiInsetCorner2 = GuiService:GetGuiInset()
    local CameraViewport = self.Camera.ViewportSize - GuiInsetCorner1 - GuiInsetCorner2
    local Width = (IsTopOrBottom and self.WindowFrame.AbsoluteSize.Y or self.WindowFrame.AbsoluteSize.X)
    local EndPosition = 0
    if not Side or Side == Enum.NormalId.Left or Side == Enum.NormalId.Top then
        EndPosition = (PositionRelative or 0.05) * (IsTopOrBottom and CameraViewport.Y or CameraViewport.X)
    elseif Side == Enum.NormalId.Right or Side == Enum.NormalId.Bottom then
        EndPosition = ((IsTopOrBottom and CameraViewport.Y or CameraViewport.X) * (1 - (PositionRelative or 0.05))) - Width
    end

    --Tween the window.
    local TweenPosition = UDim2.new(0, EndPosition, 0, FixedPosition)
    if IsTopOrBottom then
        TweenPosition = UDim2.new(0, FixedPosition, 0, EndPosition)
    end
    if GuiService.ReducedMotionEnabled then
        self.WindowFrame.Position = TweenPosition
    else
        TweenService:Create(self.WindowFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, EasingDirection or Enum.EasingDirection.Out), {
            Position = TweenPosition,
        }):Play()
    end

    --Call the finish callback.
    if FinishCallback then
        task.delay(0.5, FinishCallback)
    end
end

--[[
Tweens a window out of view.
--]]
function Window:TweenOut(Side: Enum.NormalId?, FinishCallback: (() -> ())?): ()
    local GuiInsetCorner1, GuiInsetCorner2 = GuiService:GetGuiInset()
    local CameraViewport = self.Camera.ViewportSize - GuiInsetCorner1 - GuiInsetCorner2
    local IsTopOrBottom = (Side == Enum.NormalId.Top or Side == Enum.NormalId.Bottom)
    local RelativeOffset = -1.1 * (IsTopOrBottom and (self.WindowFrame.AbsoluteSize.Y / CameraViewport.Y) or (self.WindowFrame.AbsoluteSize.X / CameraViewport.X))
    self:TweenTo(Side, RelativeOffset, FinishCallback, Enum.EasingDirection.In)
end

--[[
Destroys the window.
---]]
function Window:Destroy()
    --Disconnect the events.
    for _,Event in pairs(self.Events) do
        Event:Disconnect()
    end

    --Destroy the frames.
    self.Background:Destroy()
    self.TopBarBackground:Destroy()
    if self.RefreshButton then self.RefreshButton:Destroy() end
    if self.CloseButton then self.CloseButton:Destroy() end
end



return Window