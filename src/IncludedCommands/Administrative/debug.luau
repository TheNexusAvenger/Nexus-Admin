--Implementation of a command.
--!strict

local MESSAGE_TYPE_TO_COLOR = {
    [Enum.MessageType.MessageError] = Color3.fromRGB(255, 0, 0),
    [Enum.MessageType.MessageInfo] = Color3.fromRGB(102, 127, 255),
    [Enum.MessageType.MessageWarning] = Color3.fromRGB(255, 153, 102),
}

local LogService = game:GetService("LogService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "debug",
    Category = "Administrative",
    Description = "Displays the output of the server.",
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        --Create the logs.
        local ServerOutputLogs = Api.Logs.new()
        Api.LogsRegistry:RegisterLogs("ServerOutput", ServerOutputLogs, Api.Configuration:GetCommandAdminLevel("Administrative", "debug"))

        --Listen for new output messages.
        LogService.MessageOut:Connect(function(Message, MessageType)
            ServerOutputLogs:Add({
                Text = Message,
                TextColor3 = MESSAGE_TYPE_TO_COLOR[MessageType],
            })
        end)

        --Add the existing output.
        for _, Line in LogService:GetLogHistory() do
            ServerOutputLogs:Add({
                Text = Line.message,
                TextColor3 = MESSAGE_TYPE_TO_COLOR[Line.messageType],
            })
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Command: string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local Window = ScrollingTextWindow.new()
        Window.Title = "Server Output"
        Window:DisplayLogs(Api.LogsRegistry:GetLogs("ServerOutput"), true)
        Window:Show()
    end,
}