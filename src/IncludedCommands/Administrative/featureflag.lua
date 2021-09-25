--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper({"featureflag","feature"},"Administrative","Sets the value of a feature flag.")

    self.Arguments = {
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
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,FeatureFlags,Value)
    self.super:Run(CommandContext)

    --Change the feature flags.
    for _,FeatureFlag in pairs(FeatureFlags) do
        self.API.FeatureFlags:SetFeatureFlag(FeatureFlag,Value)
    end
end



return Command