--[[
TheNexusAvenger

Implementation of a command.
--]]
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
            warn("Failed to get feature flag logs because "..tostring(ErrorMessage))
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
                        table.insert(Logs, Api.Time:GetDateTimeString(Log.Time)..": "..Log.UserName.." changed "..Log.Name.." from "..tostring(Log.PreviousValue).." to "..tostring(Log.NewValue))
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
        local Api = Util:GetApi()
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local FeatureFlagLogs = nil
        local Window = ScrollingTextWindow.new()
        Window.Title = "Feature Flag Logs"
        Window.GetTextLines = function(_, SearchTerm, ForceRefresh)
            --Get the logs.
            if not FeatureFlagLogs or ForceRefresh then
                FeatureFlagLogs = (Api.EventContainer:WaitForChild("GetFeatureFlagLogs") :: RemoteFunction):InvokeServer()
            end

            --Filter and return the feature flags logs.
            local FilteredLogs = {}
            for _, Message in FeatureFlagLogs do
                if string.find(string.lower(Message), string.lower(SearchTerm)) then
                    table.insert(FilteredLogs, Message)
                end
            end
            return FilteredLogs
        end
        Window:Show()
    end,
}