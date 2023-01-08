--[[
TheNexusAvenger

Type representing a registered feature flag.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

--[[
Registers the types.
--]]
return function(API: Types.NexusAdminApi)
    --Create the feature flag types.
    local FeatureFlagType = {
        --[[
        Transforms the string to a list of fast flags.
        --]]
        Transform = function(Text: string): {string}
            return API.Cmdr.Util.MakeFuzzyFinder(API.FeatureFlags:GetAllFeatureFlags())(Text)
        end,

        --[[
        Returns if the input is valid and an error message
        for when it is invalid.
        --]]
        Validate = function(FeatureFlags: {string}): (boolean, string)
            return #FeatureFlags > 0, "No feature flags with that name were found."
        end,

        --[[
        Returns the results for auto completing.
        --]]
        Autocomplete = function(FeatureFlags: {string}): {string}
            return FeatureFlags
        end,

        --[[
        Returns the value to use.
        --]]
        Parse = function(FeatureFlags: {string}): string
            return FeatureFlags[1]
        end,
    }
    local FeatureFlagsType = {
        Listable = true,
        Transform = FeatureFlagType.Transform,
        Validate = FeatureFlagType.Validate,
        Autocomplete = FeatureFlagType.Autocomplete,

        --[[
        Returns the value to use.
        --]]
        Parse = function(FeatureFlags: {string}): {string}
            return FeatureFlags
        end,
    }

    --Register the types.
    API.Cmdr.Registry:RegisterType("nexusAdminFastFlag", FeatureFlagType :: any)
    API.Cmdr.Registry:RegisterType("nexusAdminFastFlags", FeatureFlagsType :: any)
end