--[[
TheNexusAvenger

Base class for handling feature flags.
--]]

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))
local NexusEvent = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("Event"):WaitForChild("NexusEvent"))

local FeatureFlags = NexusObject:Extend()
FeatureFlags:SetClassName("FeatureFlags")



--[[
Creates a feature flags instance.
--]]
function FeatureFlags:__new()
    self:InitializeSuper()
    
    self.FeatureFlags = {}
    self.DefaultFeatureFlags = {}
    self.FeatureFlagChanged = NexusEvent.new()
    self.FeatureFlagChangedNameEvents = {}
end

--[[
Adds a feature flag if it wasn't set before.
--]]
function FeatureFlags:AddFeatureFlag(Name,Value)
    self.DefaultFeatureFlags[Name] = Value
    if self.FeatureFlags[Name] == nil then
        self.FeatureFlags[Name] = Value
    end
end

--[[
Sets a feature flag value.
--]]
function FeatureFlags:SetFeatureFlag(Name,Value)
    if self.FeatureFlags[Name] == nil then
        --Add the feature flag if it doesn't exist.
        self:AddFeatureFlag(Name,Value)
    elseif self.FeatureFlags[Name] ~= Value then
        --Change the feature flag if it changed.
        self.FeatureFlags[Name] = Value
        self.FeatureFlagChanged:Fire(Name,Value)
        if self.FeatureFlagChangedNameEvents[Name] then
            self.FeatureFlagChangedNameEvents[Name]:Fire(Value)
        end
    end
end

--[[
Returns the feature flag value.
--]]
function FeatureFlags:GetFeatureFlag(Name)
    return self.FeatureFlags[Name]
end

--[[
Returns an event for a specific feature flag changing.
--]]
function FeatureFlags:GetFeatureFlagChangedEvent(Name)
    --Create the event if it doesn't exist.
    if not self.FeatureFlagChangedNameEvents[Name] then
        self.FeatureFlagChangedNameEvents[Name] = NexusEvent.new()
    end

    --Return the event.
    return self.FeatureFlagChangedNameEvents[Name]
end



return FeatureFlags