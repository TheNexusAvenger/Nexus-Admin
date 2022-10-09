--[[
TheNexusAvenger

Implementation of a command.
--]]

local MESSAGE_TYPE_TO_COLOR = {
    [Enum.MessageType.MessageError] = Color3.fromRGB(255, 0, 0),
    [Enum.MessageType.MessageInfo] = Color3.fromRGB(102, 127, 255),
    [Enum.MessageType.MessageWarning] = Color3.fromRGB(255, 153, 102),
}

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Logs = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("Logs"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("debug","Administrative","Displays the output of the server.")
    self.ServerOutputLogs = Logs.new()
    self.API.LogsRegistry:RegisterLogs("ServerOutput", self.ServerOutputLogs, self.AdminLevel)

    --Listen for new output messages.
    self.LogService.MessageOut:Connect(function(Message, MessageType)
        self.ServerOutputLogs:Add({
            Text = Message,
            TextColor3 = MESSAGE_TYPE_TO_COLOR[MessageType],
        })
    end)

    --Add the existing output.
    for _, Line in pairs(self.LogService:GetLogHistory()) do
        self.ServerOutputLogs:Add({
            Text = Line.message,
            TextColor3 = MESSAGE_TYPE_TO_COLOR[Line.messageType],
        })
    end
end



return Command