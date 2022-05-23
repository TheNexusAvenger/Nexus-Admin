--[[
TheNexusAvenger

Window for sending private chats.
--]]

local Window = require(script.Parent.Parent.Parent:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("Window"))
local NexusButton = script.Parent.Parent.Parent:WaitForChild("NexusButton")
local TextButtonFactory = require(NexusButton:WaitForChild("Factory"):WaitForChild("TextButtonFactory"))

local SendFactory = TextButtonFactory.CreateDefault(Color3.new(0,200/255,0))
SendFactory:SetTextDefault("Font",Enum.Font.SciFi)
SendFactory:SetTextDefault("Text","Send")

local PrivateChatWindow = Window:Extend()
PrivateChatWindow:SetClassName("PrivateChatWindow")
PrivateChatWindow.TextService = game:GetService("TextService")
PrivateChatWindow.Players = game:GetService("Players")



--[[
Creates a private chat window.
--]]
function PrivateChatWindow:__new(Player,Message)
    self:InitializeSuper()
    self.Title = Player.Name

    --Calculate the window size.
    local CameraHeight = self.Camera.ViewportSize.Y
    local TextSize = CameraHeight * 0.5 * 0.05
    local WindowWidth = CameraHeight * 0.375
    local MessageHeight = self.TextService:GetTextSize(Message,TextSize,"SourceSans",Vector2.new(WindowWidth * 0.95,math.huge)).Y
    self.RequiredWindowHeight = MessageHeight + (5 * TextSize)

    --Create the labels.
    local MessageText = Instance.new("TextLabel")
    MessageText.BackgroundTransparency = 1
    MessageText.Size = UDim2.new(0,WindowWidth * 0.95,0,MessageHeight)
    MessageText.Position = UDim2.new(0,WindowWidth * 0.025,0,0)
    MessageText.Font = "SourceSans"
    MessageText.Text = Message
    MessageText.TextColor3 = Color3.new(1,1,1)
    MessageText.TextStrokeColor3 = Color3.new(0,0,0)
    MessageText.TextStrokeTransparency = 0
    MessageText.TextWrapped = true
    MessageText.TextSize = TextSize
    MessageText.Parent = self.ContentsAdorn

    local MessageBox = Instance.new("TextBox")
    MessageBox.Size = UDim2.new(0.95,0,0,TextSize * 3)
    MessageBox.Position = UDim2.new(0.025,0,0,MessageHeight + (0.25 * TextSize))
    MessageBox.BackgroundTransparency = 0.75
    MessageBox.BorderSizePixel = 0
    MessageBox.BackgroundColor3 = Color3.new(0,0,0)
    MessageBox.ClearTextOnFocus = false
    MessageBox.Font = "SourceSans"
    MessageBox.Text = ""
    MessageBox.Name = "CommandBox"
    MessageBox.TextColor3 = Color3.new(1,1,1)
    MessageBox.TextStrokeColor3 = Color3.new(0,0,0)
    MessageBox.TextStrokeTransparency = 0
    MessageBox.TextScaled = true
    MessageBox.TextWrapped = true
    MessageBox.Parent = self.ContentsAdorn
    
    local TextSizeConstraint = Instance.new("UITextSizeConstraint")
    TextSizeConstraint.MaxTextSize = TextSize
    TextSizeConstraint.Parent = MessageBox

    local SendButton = SendFactory:Create()
    SendButton.Size = UDim2.new(0.4,0,0,TextSize * 1.5)
    SendButton.Position = UDim2.new(0.3,0,0,MessageHeight + (3.5 * TextSize))
    SendButton.Parent = self.ContentsAdorn

    --Connect the buttons.
    local DB = true
    SendButton.MouseButton1Down:Connect(function()
        if DB then
            DB = false
            self.object:OnMessage(MessageBox.Text)
        end
    end)
end

--[[
Shows the window.
--]]
function PrivateChatWindow:Show()
    --Create the ScreenGui.
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusAdminPrivateMessageWindow"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = self.Players.LocalPlayer:FindFirstChild("PlayerGui")
    self.ScreenGui = ScreenGui

    --Move the window off-screen.
    local CameraViewport = self.Camera.ViewportSize
    self.WindowFrame.Position = UDim2.new(0,(CameraViewport.X * 0.5) - (CameraViewport.Y * 0.375/2),0,CameraViewport.Y * -0.5)

    --Update the window and show the window.
    self.WindowFrame.Parent = ScreenGui
    local WindowHeight = self.ContentsAdorn.Size.Y.Offset - self.RequiredWindowHeight
    self.WindowFrame.Size = UDim2.new(0,CameraViewport.Y * 0.375,0,WindowHeight)
    self.WindowFrame:TweenPosition(UDim2.new(0,(CameraViewport.X * 0.5) - (CameraViewport.Y * 0.375/2),0,CameraViewport.Y * 0.5 - (WindowHeight/2)),"Out","Back",0.5,false)
end

--[[
Closes the window.
--]]
function PrivateChatWindow:OnClose()
    self.WindowFrame:TweenPosition(UDim2.new(0,self.WindowFrame.AbsolutePosition.X,0,-self.WindowFrame.AbsolutePosition.Y * 1.2),"In","Back",0.5,false,function()
        self:Destroy()
        self.ScreenGui:Destroy()
    end)
end

--[[
Callback for sending a message.
--]]
function PrivateChatWindow:OnMessage(Message)

end



return PrivateChatWindow