--[[
TheNexusAvenger

Creates a display Gui for the soft shutdown.
--]]

return function(Source)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SoftShutdownGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 100

    --Create background to cover behind top bar.
    local BackgroundFrame = Instance.new("Frame")
    BackgroundFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    BackgroundFrame.Position = UDim2.new(-0.5, 0, -0.5, 0)
    BackgroundFrame.Size = UDim2.new(2, 0, 2, 0)
    BackgroundFrame.ZIndex = 10
    BackgroundFrame.Parent = ScreenGui

    local TextAdornFrame = Instance.new("Frame")
    TextAdornFrame.BackgroundTransparency = 1
    TextAdornFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
    TextAdornFrame.Size = UDim2.new(0.5, 0, 0.5, 0)
    TextAdornFrame.ZIndex = 10
    TextAdornFrame.Parent = BackgroundFrame

    --[[
    Creates a text label.
    --]]
    local function CreateTextLabel(Properties)
        local TextLabel = Instance.new("TextLabel")
        TextLabel.BackgroundTransparency = 1
        TextLabel.ZIndex = 10
        TextLabel.Font = Enum.Font.SourceSansBold
        TextLabel.TextScaled = true
        TextLabel.TextColor3 = Color3.new(1, 1, 1)
        TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        TextLabel.TextStrokeTransparency = 0
        TextLabel.Parent = TextAdornFrame
        for Key, Value in pairs(Properties) do
            TextLabel[Key] = Value
        end
    end

    --Create the main text.
    CreateTextLabel({
        Size = UDim2.new(0.5, 0, 0.08, 0),
        Position = UDim2.new(0.25, 0, 0.44, 0),
        Text = "This server is restarting",
    })
    CreateTextLabel({
        Size = UDim2.new(0.5, 0, 0.06, 0),
        Position = UDim2.new(0.25, 0, 0.525, 0),
        Text = "Please wait",
    })
    CreateTextLabel({
        Size = UDim2.new(0.5, 0, 0.05, 0),
        Position = UDim2.new(0.01, 0, 0.94, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "Nexus Admin",
    })

    --Display the source.
    if Source then
        --Determine the message.
        local SourceText = "Soft shutdown source is unknown"
        if Source.Source == "BindToClose" then
            SourceText = "BindToClose was invoked by the server. Shutting down may have been requested remotely"
        elseif Source.Source == "Player" then
            SourceText = "The soft shutdown command was invoked by "..tostring(Source.Name)
        end

        --Create the text.
        CreateTextLabel({
            Size = UDim2.new(0.5, 0, 0.04, 0),
            Position = UDim2.new(0.99, 0, 0.92, 0),
            AnchorPoint = Vector2.new(1, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = SourceText,
        })
        CreateTextLabel({
            Size = UDim2.new(0.5, 0, 0.025, 0),
            Position = UDim2.new(0.99, 0, 0.96, 0),
            AnchorPoint = Vector2.new(1, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = "The soft shutdown source is only shown to admins",
        })
    end

    --Return the ScreenGui and the background.
    return ScreenGui, BackgroundFrame
end