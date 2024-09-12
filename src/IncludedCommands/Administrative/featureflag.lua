--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local SUPPORTED_FEATURE_FLAG_TYPES = {
    ["boolean"] = true,
    ["number"] = true,
    ["string"] = true,
}

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
        function(CommandContext): Types.CmdrCommandArgument
            --Determine the type of the first feature flag.
            --Default to bool if there is none.
            local Util = IncludedCommandUtil.ForContext(CommandContext)
            local Api = Util:GetApi()
            local FeatureFlags = CommandContext.Arguments[1]:GetValue()
            local FirstFeatureFlagValue = FeatureFlags[1] and Api.FeatureFlags:GetFeatureFlag(FeatureFlags[1])
            local FirstFeatureFlagType = FirstFeatureFlagValue and typeof(FirstFeatureFlagValue) or "boolean"

            --Return an error type if the type is not supported.
            if not SUPPORTED_FEATURE_FLAG_TYPES[FirstFeatureFlagType] then
                return {
                    Type = {
                        Parse = function() return nil end,
                        Validate = function()
                            return false, `Feature flag type "{FirstFeatureFlagType}" is unsupported.`
                        end,
                    },
                    Name = "Value",
                    Description = "New value of the feature flag.",
                }
            end

            --Return an error type if the types don't match.
            for i = 2, #FeatureFlags do
                local FeatureFlagValue = Api.FeatureFlags:GetFeatureFlag(FeatureFlags[i])
                if FeatureFlagValue == nil then continue end
                if typeof(FeatureFlagValue) == FirstFeatureFlagType then continue end
                return {
                    Type = {
                        Parse = function() return nil end,
                        Validate = function()
                            return false, `Feature flags have different types. Only group together feature flags of the same type.`
                        end,
                    },
                    Name = "Value",
                    Description = "New value of the feature flag.",
                }
            end

            --Return the type for the first flag.
            return {
                Type = FirstFeatureFlagType,
                Name = "Value",
                Description = "New value of the feature flag.",
            }
        end,
    } :: {any},
    ServerRun = function(CommandContext: Types.CmdrCommandContext, FeatureFlags: {string}, Value: any)
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