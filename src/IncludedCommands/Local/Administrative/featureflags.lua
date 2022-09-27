--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local ScrollingTextWindow = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ScrollingTextWindow"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("featureflags","Administrative","Opens up a window containing the feature flags and their current value.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)

    --Display the text window.
    local Window = ScrollingTextWindow.new()
    Window.Title = "Feature Flags"
    Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
        --Filter and return the feature flags.
        local FeatureFlags = {}
        for _, FeatureFlagName in pairs(self.API.FeatureFlags:GetAllFeatureFlags()) do
            local Message = FeatureFlagName.." - "..tostring(self.API.FeatureFlags:GetFeatureFlag(FeatureFlagName))
            if string.find(string.lower(Message),string.lower(SearchTerm)) then
                table.insert(FeatureFlags,Message)
            end
        end
        table.sort(FeatureFlags)
        return FeatureFlags
    end
    Window:Show()
end



return Command