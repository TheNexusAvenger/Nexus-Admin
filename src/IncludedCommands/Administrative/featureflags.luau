--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "featureflags",
    Category = "Administrative",
    Description = "Opens up a window containing the feature flags and their current value.",
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        --Show the window.
        local Window = Api.Window:CreateWindow("Feature Flags")
        local TextList = Window:AddTextList()
        TextList:EnableSearching()

        local function UpdateText()
            local FeatureFlags = {}
            for _, FeatureFlagName in Api.FeatureFlags:GetAllFeatureFlags() do
                table.insert(FeatureFlags, `{FeatureFlagName} - {Api.FeatureFlags:GetFeatureFlag(FeatureFlagName)}`)
            end
            table.sort(FeatureFlags)
            TextList:SetLines(FeatureFlags)
        end

        task.spawn(UpdateText)
        Window:EnableRefreshing(UpdateText)
        Window:EnableClosing()
        Window:EnableResizing()
        Window:Show()
    end,
}