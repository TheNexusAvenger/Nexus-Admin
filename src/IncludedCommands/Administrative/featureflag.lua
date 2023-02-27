--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"featureflag", "feature"},
    Category = "Administrative",
    Description = "Sets the value of a feature flag.",
    Arguments = {
        {
            Type = "nexusAdminFastFlags",
            Name = "Feature",
            Description = "Feature flags to change.",
        },
        {
            Type = "boolean",
            Name = "Value",
            Description = "New value of the feature flag.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, FeatureFlags: {string}, Value: boolean)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        
        --Log the feature flag change.
        if Api.CommandData.FeatureFlagLogsDataStore then
            local PreviousValues = {}
            for _, FeatureFlag in FeatureFlags do
                PreviousValues[FeatureFlag] = Api.FeatureFlags:GetFeatureFlag(FeatureFlag)
            end
            task.spawn(function()
                Api.CommandData.FeatureFlagLogsDataStore:Update("FeatureFlagChangesLog", function(OldLogs)
                    OldLogs = OldLogs or {}
                    for _, FeatureFlag in FeatureFlags do
                        table.insert(OldLogs, {
                            Time = os.time(),
                            UserId = CommandContext.Executor.UserId,
                            UserName = CommandContext.Executor.Name,
                            Name = FeatureFlag,
                            PreviousValue = PreviousValues[FeatureFlag],
                            NewValue = Value,
                        })
                    end
                    return OldLogs
                end)
            end)
        end

        --Change the feature flags.
        for _, FeatureFlag in FeatureFlags do
            Api.FeatureFlags:SetFeatureFlag(FeatureFlag, Value)
        end
    end,
}