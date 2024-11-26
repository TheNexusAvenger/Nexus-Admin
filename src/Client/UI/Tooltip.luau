--Adds the native tooltip API.
--!strict

local TOOLTIP_SIZE_RELATIVE = 0.03

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local NexusButton = script.Parent.Parent:WaitForChild("NexusButton")
local ThemedFrame = require(NexusButton:WaitForChild("ThemedFrame"))



return function(API,Player)
    local TooptipContainer

    --[[
    Adds a tooltip to a frame.
    --]]
    function API.Gui:AddTooltipToFrame(Text,Frame)
        local Bounds = TextService:GetTextSize(Text,18,"SourceSans",Vector2.new(4096,4096))
        local BoundsXRelative,BoundsYRelative = Bounds.X/18,Bounds.Y/18
        
        --Create the ScreenGui.
        if not TooptipContainer or not TooptipContainer.Parent then
            local NewTooptipContainer = Instance.new("ScreenGui")
            NewTooptipContainer.Name = "NexusAdminTooltips"
            NewTooptipContainer.Parent = Player:FindFirstChild("PlayerGui")
            NewTooptipContainer.ResetOnSpawn = false
            TooptipContainer = NewTooptipContainer
        end

        --Create the tooltip GUI.
        local AdornFrame = Instance.new("Frame")
        AdornFrame.BackgroundTransparency = 1
        AdornFrame.Visible = false
        AdornFrame.ZIndex = 10
        AdornFrame.Parent = TooptipContainer

        local Background = ThemedFrame.new()
        Background.Size = UDim2.new(1,0,1,0)
        Background.BackgroundColor3 = Color3.new(0,0,0)
        Background.BackgroundTransparency = 0.75 * GuiService.PreferredTransparency
        Background.Parent = AdornFrame

        local TextLabel = Instance.new("TextLabel")
        TextLabel.BackgroundTransparency = 1
        TextLabel.ZIndex = 12
        TextLabel.Size = UDim2.new(1,-12,1,-12)
        TextLabel.Position = UDim2.new(0,6,0,6)
        TextLabel.TextColor3 = Color3.new(1,1,1)
        TextLabel.TextStrokeColor3 = Color3.new(0,0,0)
        TextLabel.TextStrokeTransparency = 0
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Text = Text
        TextLabel.Parent = AdornFrame
        
        --[[
        Returns if the given position is in a frame.
        --]]
        local function MouseInFrame(Frame: GuiObject, X: number, Y: number): boolean
            local PosX,PosY = Frame.AbsolutePosition.X, Frame.AbsolutePosition.Y
            local SizeX,SizeY = Frame.AbsoluteSize.X, Frame.AbsoluteSize.Y
            return (X > PosX and Y > PosY and X < PosX + SizeX and Y < PosY + SizeY)
        end
        
        --[[
        Returns if the parent is visible.
        --]]
        local function ParentsVisible(Frame,X,Y)
            local FrameParent = Frame.Parent
            if FrameParent and FrameParent:IsA("GuiObject") then
                if not FrameParent.Visible then
                    return false
                end
                
                if FrameParent.ClipsDescendants and not MouseInFrame(FrameParent :: any, X, Y) then
                    return false
                end
                
                return ParentsVisible(FrameParent,X,Y)
            end
            return true
        end
        
        local Events = {} :: {RBXScriptConnection}
        local function Update(X: number | boolean, Y: number?)
            --If the frame was unparented, disconnect the events.
            if not Frame.Parent then 
                for _, Event in Events do
                    Event:Disconnect()
                end
                Events = {}
                AdornFrame:Destroy()
                return 
            end
            
            --Update the frame.
            if X ~= true and MouseInFrame(Frame, X :: number, Y :: number) and ParentsVisible(Frame :: any, X :: number, Y :: number) then
                AdornFrame.Visible = true
                AdornFrame.Position = UDim2.new(0, (X :: number) + 20, 0, Y)
                
                local SizeY = (AdornFrame.Parent :: any).AbsoluteSize.Y * TOOLTIP_SIZE_RELATIVE
                AdornFrame.Size = UDim2.new(0,(SizeY * BoundsXRelative) + 12,0,(SizeY * BoundsYRelative) + 12)
                TextLabel.TextSize = SizeY
            else
                AdornFrame.Visible = false
            end
        end
        
        --Connect the mouse moving.
        table.insert(Events, UserInputService.InputChanged:Connect(function(Key)
            if Key.UserInputType == Enum.UserInputType.MouseMovement then
                Update(Key.Position.X,Key.Position.Y)
            end
        end))
        
        --Connect the mouse leaving the frame.
        table.insert(Events, Frame.MouseLeave:Connect(function(X,Y)
            Update(true)
        end))

        --Connect changing the background.
        table.insert(Events, GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
            Background.BackgroundTransparency = 0.75 * GuiService.PreferredTransparency
        end))
    end
end