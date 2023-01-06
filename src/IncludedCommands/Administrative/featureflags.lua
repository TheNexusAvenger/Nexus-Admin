--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "featureflags",
    Category = "Administrative",
    Description = "Opens up a window containing the feature flags and their current value.",
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local Window = ScrollingTextWindow.new()
        Window.Title = "Feature Flags"
        Window.GetTextLines = function(_, SearchTerm, ForceRefresh)
            --Filter and return the feature flags.
            local FeatureFlags = {}
            for _, FeatureFlagName in Api.FeatureFlags:GetAllFeatureFlags() do
                local Message = FeatureFlagName.." - "..tostring(Api.FeatureFlags:GetFeatureFlag(FeatureFlagName))
                if string.find(string.lower(Message), string.lower(SearchTerm)) then
                    table.insert(FeatureFlags, Message)
                end
            end
            table.sort(FeatureFlags)
            return FeatureFlags
        end
        Window:Show()
    end,
}