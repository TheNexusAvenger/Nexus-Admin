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
        
        --Change the feature flags.
        for _, FeatureFlag in FeatureFlags do
            Api.FeatureFlags:SetFeatureFlag(FeatureFlag, Value)
        end
    end,
}