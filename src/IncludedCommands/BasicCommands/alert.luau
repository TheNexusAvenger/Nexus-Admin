--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"alert"},
    Category = "BasicCommands",
    Description = "Displays an alert notification for a player.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to display the alert.",
        },
        {
            Type = "string",
            Name = "Message",
            Description = "Alert notification text.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        (IncludedCommandUtil:GetRemote("DisplayAlert") :: RemoteEvent).OnClientEvent:Connect(function(Message: string)
            Api.Messages:DisplayNotification("Alert", Message)
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        IncludedCommandUtil:CreateRemote("RemoteEvent", "DisplayAlert")
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Message: string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        local DisplayAlertEvent = Util:GetRemote("DisplayAlert") :: RemoteEvent
        for Player, FilteredMessage in Api.Filter:FilterStringForPlayers(Message, CommandContext.Executor, Players) do
            DisplayAlertEvent:FireClient(Player, Message)
        end
    end,
}