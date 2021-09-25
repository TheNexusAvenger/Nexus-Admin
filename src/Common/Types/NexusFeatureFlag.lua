--[[
TheNexusAvenger

Type representing a registered feature flag.
--]]

--[[
Registers the types.
--]]
return function(API)
    --Create the feature flag types.
    local FeatureFlagType = {
        --[[
        Transforms the string to a list of fast flags.
        --]]
        Transform = function(Text)
            --Get the feature flags.
            local FeatureFlags = {}
            for FeatureFlag,_ in pairs(API.FeatureFlags.FeatureFlags) do
                table.insert(FeatureFlags,FeatureFlag)
            end

            --Find and return the feature flags.
            local FindFastFlags = API.Cmdr.Util.MakeFuzzyFinder(FeatureFlags)
            return FindFastFlags(Text)
        end,

        --[[
        Returns if the input is valid and an error message
        for when it is invalid.
        --]]
        Validate = function(FeatureFlags)
            return #FeatureFlags,"No feature flags with that name were found."
        end,

        --[[
        Returns the results for auto completing.
        --]]
        Autocomplete = function(FeatureFlags)
            return FeatureFlags
        end,

        --[[
        Returns the value to use.
        --]]
        Parse = function(FeatureFlags)
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
        Parse = function(FeatureFlags)
            return FeatureFlags
        end,
    }

    --Register the types.
    API.Cmdr.Registry:RegisterType("nexusAdminFastFlag",FeatureFlagType)
    API.Cmdr.Registry:RegisterType("nexusAdminFastFlags",FeatureFlagsType)
end