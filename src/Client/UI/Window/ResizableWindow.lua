--[[
TheNexusAvenger

Extension of the Window class to add resizing.
--]]

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Window = require(script.Parent:WaitForChild("Window"))

local NexusButton = script.Parent.Parent.Parent:WaitForChild("NexusButton")
local ThemedFrame = require(NexusButton:WaitForChild("ThemedFrame"))

local ResizableWindow = Window:Extend()
ResizableWindow:SetClassName("ResizableWindow")



--[[
Creates the resizable window.
--]]
function ResizableWindow:__new(MinWidth,MinHeight,MaxWidth,MaxHeight)
    self:InitializeSuper()

    --Calculate the heights.
    local ViewportSize = self.Camera.ViewportSize
    local WindowHeight = ViewportSize.Y * 0.5
    local TopBarHeightPixel = WindowHeight * 0.1
    local CornerSizePixel = TopBarHeightPixel * 0.4
    local ResizeCornerSizePixel = CornerSizePixel * 1.5
    MinWidth = MinWidth or WindowHeight * 0.6
    MinHeight = MinHeight or TopBarHeightPixel * 2
    MaxWidth = MaxWidth or math.huge
    MaxHeight = MaxHeight or math.huge

    --Create the resize corner.
    local ResizeCornerAdorn = Instance.new("TextButton")
    ResizeCornerAdorn.Size = UDim2.new(0,ResizeCornerSizePixel,0,ResizeCornerSizePixel)
    ResizeCornerAdorn.Position = UDim2.new(1,-ResizeCornerSizePixel,1,-ResizeCornerSizePixel)
    ResizeCornerAdorn.BackgroundTransparency = 1
    ResizeCornerAdorn.Text = ""
    ResizeCornerAdorn.Parent = self.WindowFrame

    local ResizeCorner = ThemedFrame.new()
    ResizeCorner.BackgroundColor3 = Color3.new(1,1,1)
    ResizeCorner.BackgroundTransparency = 0.5 * GuiService.PreferredTransparency
    ResizeCorner.Size = UDim2.new(1,0,1,0)
    ResizeCorner.Theme = "CutBottomRightCorner"
    ResizeCorner.SliceScaleMultiplier = 2
    ResizeCorner.Parent = ResizeCornerAdorn
    self.ResizeCorner = ResizeCorner

    --Connect the events.
    self.Events = {}
    local MouseDown = false
    local LastPosition
    local IntendedSizeX,IntendedSizeY
    table.insert(self.Events,ResizeCornerAdorn.MouseButton1Down:Connect(function()
        MouseDown = true
        LastPosition = UserInputService:GetMouseLocation()
        IntendedSizeX,IntendedSizeY = self.WindowFrame.Size.X.Offset,self.WindowFrame.Size.Y.Offset
    end))

    table.insert(self.Events,self.UserInputService.InputChanged:Connect(function(Input)
        if LastPosition and MouseDown and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local MousePosition = UserInputService:GetMouseLocation()
            local Delta = MousePosition - LastPosition
            LastPosition =  MousePosition
            IntendedSizeX,IntendedSizeY = IntendedSizeX + Delta.X,IntendedSizeY + Delta.Y
            self.WindowFrame.Size = UDim2.new(0,math.clamp(IntendedSizeX,MinWidth,MaxWidth),0,math.clamp(IntendedSizeY + Delta.Y,MinHeight,MaxHeight))
        end
    end))

    table.insert(self.Events,self.UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            MouseDown = false
            LastPosition = nil
            IntendedSizeX,IntendedSizeY = nil,nil
        end
    end))

    table.insert(self.Events, GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
        ResizeCorner.BackgroundTransparency = 0.5 * GuiService.PreferredTransparency
    end))
end

--[[
Destroys the window.
---]]
function ResizableWindow:Destroy()
    self.super:Destroy()
    self.ResizeCorner:Destroy()
end



return ResizableWindow