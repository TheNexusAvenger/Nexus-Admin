--[[
TheNexusAvenger

Adds the native tooltip API.
--]]

local TOOLTIP_SIZE_RELATIVE = 0.03
local TOOLTIP_BORDER_CUT_RELATIVE = 0.2

local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local NexusButton = script.Parent.Parent:WaitForChild("NexusButton")
local CutFrame = require(NexusButton:WaitForChild("Gui"):WaitForChild("CutFrame"))



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
            TooptipContainer = Instance.new("ScreenGui")
            TooptipContainer.Name = "NexusAdminTooltips"
            TooptipContainer.Parent = Player:FindFirstChild("PlayerGui")
			TooptipContainer.ResetOnSpawn = false
        end

        --Create the tooltip GUI.
        local AdornFrame = Instance.new("Frame")
        AdornFrame.BackgroundTransparency = 1
        AdornFrame.Visible = false
        AdornFrame.ZIndex = 10
        AdornFrame.Parent = TooptipContainer

        local Background = CutFrame.new(AdornFrame)
        Background.BackgroundColor3 = Color3.new(0,0,0)
        Background.BackgroundTransparency = 0.75
        Background:CutCorner("Top","Left",UDim2.new(TOOLTIP_BORDER_CUT_RELATIVE/BoundsYRelative,0,TOOLTIP_BORDER_CUT_RELATIVE/BoundsYRelative,0),"RelativeYY")
        Background:CutCorner("Bottom","Right",UDim2.new(TOOLTIP_BORDER_CUT_RELATIVE/BoundsYRelative,0,TOOLTIP_BORDER_CUT_RELATIVE/BoundsYRelative,0),"RelativeYY")
		
		local TextLabel = Instance.new("TextLabel")
		TextLabel.BackgroundTransparency = 1
		TextLabel.ZIndex = 12
		TextLabel.Size = UDim2.new(1,-12,1,-12)
		TextLabel.Position = UDim2.new(0,6,0,6)
		TextLabel.TextColor3 = Color3.new(1,1,1)
		TextLabel.TextStrokeColor3 = Color3.new(0,0,0)
		TextLabel.TextStrokeTransparency = 0
        TextLabel.Font = "SourceSans"
        TextLabel.TextXAlignment = "Left"
		TextLabel.Text = Text
		TextLabel.Parent = AdornFrame
        
        --[[
        Returns if the given position is in a frame.
        --]]
		local function MouseInFrame(Frame,X,Y)
			local PosX,PosY = Frame.AbsolutePosition.X,Frame.AbsolutePosition.Y
			local SizeX,SizeY = Frame.AbsoluteSize.X,Frame.AbsoluteSize.Y
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
                
				if FrameParent.ClipsDescendants and not MouseInFrame(FrameParent,X,Y) then
					return false
				end
				
				return ParentsVisible(FrameParent,X,Y)
			end
			return true
		end
		
		local Event1,Event2
        local function Update(X,Y)
            --If the frame was unparented, disconnect the events.
			if not Frame.Parent then 
				if Event1 then Event1:Disconnect() end 
				if Event2 then Event2:Disconnect() end 
				AdornFrame:Destroy()
				return 
			end
            
            --Update the frame.
			if X ~= true and MouseInFrame(Frame,X,Y) and ParentsVisible(Frame,X,Y) then
				AdornFrame.Visible = true
				AdornFrame.Position = UDim2.new(0,X + 20,0,Y)
				
				local SizeY = AdornFrame.Parent.AbsoluteSize.Y * TOOLTIP_SIZE_RELATIVE
				AdornFrame.Size = UDim2.new(0,(SizeY * BoundsXRelative) + 12,0,(SizeY * BoundsYRelative) + 12)
				TextLabel.TextSize = SizeY
			else
				AdornFrame.Visible = false
			end
		end
        
        --Connect the mouse moving.
		Event1 = UserInputService.InputChanged:Connect(function(Key)
			if Key.UserInputType == Enum.UserInputType.MouseMovement then
				Update(Key.Position.X,Key.Position.Y)
			end
		end)
        
        --Connect the mouse leaving the frame.
		Event2 = Frame.MouseLeave:Connect(function(X,Y)
			Update(true)
		end)
    end
end