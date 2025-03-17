--Implementation of a command.
--!strict

local LogService = game:GetService("LogService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "localdebug",
    Category = "Administrative",
    Description = "Displays the output of a client.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to get the local logs of.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApi)
        --Connect the remote function.
        (Api.EventContainer:WaitForChild("GetClientOutput") :: RemoteFunction).OnClientInvoke = function()
            local Output = {}
            for _,Line in LogService:GetLogHistory() do
                local LineData = {
                    Font = Enum.Font.Code,
                    Text = Line.message,
                }
                table.insert(Output,LineData)

                if Line.messageType == Enum.MessageType.MessageError then
                    LineData.TextColor3 = Color3.fromRGB(255, 0, 0)
                elseif Line.messageType == Enum.MessageType.MessageInfo then
                    LineData.TextColor3 = Color3.fromRGB(102, 127, 255)
                elseif Line.messageType == Enum.MessageType.MessageWarning then
                    LineData.TextColor3 = Color3.fromRGB(255, 153, 102)
                end
            end

            return Output
        end
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        --Create the remote function.
        local GetClientOutputRemoteFunction = Instance.new("RemoteFunction")
        GetClientOutputRemoteFunction.Name = "GetClientOutput"
        GetClientOutputRemoteFunction.Parent = Api.EventContainer

        function GetClientOutputRemoteFunction.OnServerInvoke(Player, TargetPlayer)
            if not TargetPlayer or not TargetPlayer.Parent then
                return {"Disconnected"}
            elseif Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("Administrative", "localdebug")) then
                return GetClientOutputRemoteFunction:InvokeClient(TargetPlayer)
            else
                return {"Unauthorized"}
            end
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        --Show the windows.
        for _, Player in Players do
            local Window = Api.Window:CreateWindow(`Client Output - {Player.DisplayName} ({Player.Name})`)
            local TextList = Window:AddTextList()
            TextList:EnableSearching()
    
            local function UpdateText()
                TextList:SetLines({"Loading..."})
                TextList:SetLines((Api.EventContainer:WaitForChild("GetClientOutput") :: RemoteFunction):InvokeServer(Player))
            end
    
            task.spawn(UpdateText)
            Window:EnableRefreshing(UpdateText)
            Window:EnableClosing()
            Window:EnableResizing()
            Window:Show()
        end
    end,
}