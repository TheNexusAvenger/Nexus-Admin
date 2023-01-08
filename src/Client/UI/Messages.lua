--[[
TheNexusAvenger

Adds message UI functionality to the API.
--]]
--!strict

local HINT_HEIGHT_RELATIVE = 0.035
local MAX_HINTS = 5

local Types = require(script.Parent.Parent:WaitForChild("Types"))


--[[
Adds native messages.
--]]
local function AddNativeMessages(API: Types.NexusAdminApiClient, Player: Player): ()
    local NexusAdminMessagesScreenGui = nil
    
    --Connect displaying messages.
    (API.EventContainer:WaitForChild("MessageEvents"):WaitForChild("DisplayMessageLoopback") :: BindableEvent).Event:Connect(function(TopText: string, Message: string, DisplayTime: number?)
        if API.FeatureFlags:GetFeatureFlag("UseNativeMessageGui") then
            TopText = TopText or ""
            Message = Message or ""
            if not DisplayTime then DisplayTime = (string.len(TopText) + string.len(Message)) * 0.05 + 0.4 end

            --Create the ScreenGui if it doesn't exist.
            if not NexusAdminMessagesScreenGui or not NexusAdminMessagesScreenGui.Parent then
                local NewNexusAdminMessagesScreenGui = Instance.new("ScreenGui")
                NewNexusAdminMessagesScreenGui.Name = "NexusAdminMessagesScreenGui"
                NewNexusAdminMessagesScreenGui.Parent = Player:FindFirstChild("PlayerGui")
                NewNexusAdminMessagesScreenGui.ResetOnSpawn = false
                NexusAdminMessagesScreenGui = NewNexusAdminMessagesScreenGui
            end

            --Create the text.
            local TextLabel = Instance.new("TextLabel")
            TextLabel.BackgroundTransparency = 0.5
            TextLabel.BorderSizePixel = 0
            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.Position = UDim2.new(0, 0, -1, 0)
            TextLabel.BackgroundColor3 = Color3.new(0, 0, 0)
            TextLabel.Font = Enum.Font.SourceSans
            TextLabel.TextWrapped = true
            TextLabel.Text = Message
            TextLabel.RichText = true
            TextLabel.TextColor3 = Color3.new(1, 1, 1)
            TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            TextLabel.TextStrokeTransparency = 0
            TextLabel.Parent = NexusAdminMessagesScreenGui
            
            local TopTextLabel = Instance.new("TextLabel")
            TopTextLabel.BackgroundTransparency = 1
            TopTextLabel.Size = UDim2.new(1, 0, 0.05, 0)
            TopTextLabel.BackgroundColor3 = Color3.new(0, 0, 0)
            TopTextLabel.Font = Enum.Font.SourceSansBold
            TopTextLabel.Text = TopText
            TopTextLabel.RichText = true
            TopTextLabel.TextColor3 = Color3.new(1, 1, 1)
            TopTextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            TopTextLabel.TextStrokeTransparency = 0
            TopTextLabel.Parent = TextLabel
            TextLabel.TextSize = TextLabel.AbsoluteSize.Y * 0.05
            TopTextLabel.TextSize = TopTextLabel.AbsoluteSize.Y
            
            --Connect the event for resizing.
            local Event = NexusAdminMessagesScreenGui:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                TextLabel.TextSize = TextLabel.AbsoluteSize.Y * 0.035
                TopTextLabel.TextSize = TopTextLabel.AbsoluteSize.Y
            end)
            
            --Tween the frame in and out.
            TextLabel:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.5, true, function()
                task.wait(DisplayTime)
                TextLabel:TweenPosition(UDim2.new(0, 0, 1, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.5, true, function()
                    TextLabel:Destroy()
                    Event:Disconnect()
                end)
            end)
        end
    end)
end

--[[
Adds native hints.
--]]
local function AddNativeHints(API: Types.NexusAdminApiClient, Player: Player): ()
    local HintsQueue = {} :: {{Frame: TextLabel, Duration: number}}
    local NexusAdminHintsScreenGui = nil

    --[[
    Updates the position of the hints.
    --]]
    local function UpdateHintPositions()
        for i, HintData in HintsQueue do
            HintData.Frame:TweenPosition(UDim2.new(0, 0, (i - 1) * HINT_HEIGHT_RELATIVE, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true)
        end
    end

    --[[
    Removes a hint.
    --]]
    local function RemoveHint(HintData: {Frame: TextLabel, Duration: number}): ()
        --Determine the index of the hint and return if it doesn't exist.
        local Index
        for i, OtherHintData in HintsQueue do
            if HintData == OtherHintData then
                Index = i
                break
            end
        end
        if not Index then return end

        --Remove the hint and update the other hint positions.
        table.remove(HintsQueue,Index)
        HintData.Frame:TweenPosition(UDim2.new(1, 0, (Index - 1) * HINT_HEIGHT_RELATIVE, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true, function()
            HintData.Frame:Destroy()
        end)
        UpdateHintPositions()
    end

    --[[
    Inserts a hint into the queue.
    --]]
    local function InsertHint(Frame: TextLabel, Duration: number): ()
        --Insert the hint and update the positions.
        local HintData = {Frame = Frame,Duration=Duration}
        table.insert(HintsQueue, 1, HintData)
        Frame.Parent = NexusAdminHintsScreenGui
        UpdateHintPositions()
        
        --Remove the overflow hints if they exist.
        local OverflowHint = HintsQueue[MAX_HINTS + 1]
        if OverflowHint then
            HintsQueue[MAX_HINTS + 1] = nil
            OverflowHint.Frame:TweenPosition(UDim2.new(0, 0, MAX_HINTS * HINT_HEIGHT_RELATIVE, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true, function()
                OverflowHint.Frame:TweenPosition(UDim2.new(1, 0, MAX_HINTS * HINT_HEIGHT_RELATIVE, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true, function()
                    OverflowHint.Frame:Destroy()
                end)
            end)
        end

        --Remove the notification after the duration.
        task.wait(Duration)
        RemoveHint(HintData)
    end

    --Connect displaying hints.
    (API.EventContainer:WaitForChild("MessageEvents"):WaitForChild("DisplayHintLoopback") :: BindableEvent).Event:Connect(function(Message, DisplayTime)
        if API.FeatureFlags:GetFeatureFlag("UseNativeHintGui") then
            Message = Message or ""
            if not DisplayTime then DisplayTime = string.len(Message) * 0.05 + 0.4 end

            --Create the ScreenGui if it doesn't exist.
            if not NexusAdminHintsScreenGui or not NexusAdminHintsScreenGui.Parent then
                local NewNexusAdminHintsScreenGui = Instance.new("ScreenGui")
                NewNexusAdminHintsScreenGui.Name = "NexusAdminHintsScreenGui"
                NewNexusAdminHintsScreenGui.Parent = Player:FindFirstChild("PlayerGui")
                NewNexusAdminHintsScreenGui.ResetOnSpawn = false
                NexusAdminHintsScreenGui = NewNexusAdminHintsScreenGui
            end

            --Create the hint frame.
            local HintFrame = Instance.new("TextLabel")
            HintFrame.BackgroundTransparency = 0.5
            HintFrame.BorderSizePixel = 0
            HintFrame.BackgroundColor3 = Color3.new(0,0,0)
            HintFrame.Position = UDim2.new(0, 0, -HINT_HEIGHT_RELATIVE, 0)
            HintFrame.Size = UDim2.new(1, 0, HINT_HEIGHT_RELATIVE, 0)
            HintFrame.Font = Enum.Font.SourceSans
            HintFrame.TextScaled = true
            HintFrame.TextColor3 = Color3.new(1, 1, 1)
            HintFrame.TextStrokeColor3 = Color3.new(0, 0, 0)
            HintFrame.Text = Message
            HintFrame.RichText = true
            HintFrame.TextStrokeTransparency = 0
            
            --Add the hint.
            InsertHint(HintFrame, DisplayTime)
        end
    end)
end

--[[
Adds notifications to the local admin level being changed.
--]]
local function AddAdminLevelNotifications(API: Types.NexusAdminApiClient, Player: Player): ()
    local WasAuthorized = false

    --[[
    Displays a message for the admin level changing.
    --]]
    local function AdminLevelChanged()
        local IsAuthorized = API.Authorization:IsPlayerAuthorized(Player,1)
        if API.FeatureFlags:GetFeatureFlag("DisplayAdminLevelNotifications") and WasAuthorized ~= IsAuthorized then
            WasAuthorized = IsAuthorized

            --Display a message.
            if IsAuthorized then
                API.Messages:DisplayMessage("Nexus Admin","You are an admin. Use "..API.Configuration.CommandPrefix.."cmds or !cmds to view the commands. Use !usage to view using the system.")
            else
                API.Messages:DisplayHint("[Nexus Admin]: You are no longer an admin.")
            end
        end
    end

    --Initialize the admin level.
    API.Authorization.AdminLevelChanged:Connect(function(OtherPlayer,_)
        if Player == OtherPlayer then
            AdminLevelChanged()
        end
    end)
    AdminLevelChanged()
end



return function(API: Types.NexusAdminApiClient, Player: Player)
    AddNativeMessages(API, Player)
    AddNativeHints(API, Player)
    AddAdminLevelNotifications(API, Player)
end