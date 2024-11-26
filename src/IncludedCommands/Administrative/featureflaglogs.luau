--Implementation of a command.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "featureflaglogs",
    Category = "Administrative",
    Description = "Opens up a window logs of feature flag changes.",
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local NexusDataStore = require(ReplicatedStorage:WaitForChild("NexusAdminClient"):WaitForChild("NexusFeatureFlags"):WaitForChild("NexusDataStore")) :: any
        xpcall(function()
            Api.CommandData.FeatureFlagLogsDataStore = NexusDataStore:GetDataStore("NexusAdmin_Persistence", "FeatureFlagLogs")
        end, function(ErrorMessage)
            warn(`Failed to get feature flag logs because {ErrorMessage}`)
        end)

        local GetFeatureFlagLogsFunction = Instance.new("RemoteFunction")
        GetFeatureFlagLogsFunction.Name = "GetFeatureFlagLogs"
        GetFeatureFlagLogsFunction.Parent = Api.EventContainer
    
        function GetFeatureFlagLogsFunction.OnServerInvoke(Player): {string}
            if Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("Administrative", "featureflaglogs")) then
                if Api.CommandData.FeatureFlagLogsDataStore then
                    local LogEntries = Api.CommandData.FeatureFlagLogsDataStore:Get("FeatureFlagChangesLog") or {}
                    local Logs = {}
                    for i = #LogEntries, 1, -1 do
                        local Log = LogEntries[i]
                        table.insert(Logs, `{Api.Time:GetDateTimeString(Log.Time)}: {Log.UserName} changed {Log.Name} from {Log.PreviousValue} to {Log.NewValue}`)
                    end
                    return Logs
                else
                    return {"Logs failed to load."}
                end
            else
                return {"Unauthorized"}
            end
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        --Show the window.
        local Window = Api.Window:CreateWindow("Feature Flag Logs")
        local TextList = Window:AddTextList()
        TextList:EnableSearching()

        local function UpdateText()
            TextList:SetLines({"Loading..."})
            TextList:SetLines((Api.EventContainer:WaitForChild("GetFeatureFlagLogs") :: RemoteFunction):InvokeServer())
        end

        task.spawn(UpdateText)
        Window:EnableRefreshing(UpdateText)
        Window:EnableClosing()
        Window:EnableResizing()
        Window:Show()
    end,
}