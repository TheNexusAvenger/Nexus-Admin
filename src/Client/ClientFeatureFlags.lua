--[[
TheNexusAvenger

Handles feature flags on the client.
--]]

local FeatureFlags = require(script.Parent:WaitForChild("Common"):WaitForChild("FeatureFlags"))

local ClientFeatureFlags = FeatureFlags:Extend()
ClientFeatureFlags:SetClassName("ClientFeatureFlags")



--[[
Creates a client feature flag instance.
--]]
function ClientFeatureFlags:__new(NexusAdminRemotes)
    self:InitializeSuper()
    
    --Set up the events.
    local FeatureFlagEvents = NexusAdminRemotes:WaitForChild("FeatureFlagEvents")
    local GetFeatureFlags = FeatureFlagEvents:WaitForChild("GetFeatureFlags")
    local FeatureFlagChanged = FeatureFlagEvents:WaitForChild("FeatureFlagChanged")
    FeatureFlagChanged.OnClientEvent:Connect(function(Name,Value)
        self:SetFeatureFlag(Name,Value)
    end)

    --Initialize the initial feature flags.
    for Name,Value in pairs(GetFeatureFlags:InvokeServer()) do
        self:SetFeatureFlag(Name,Value)
    end
end



return ClientFeatureFlags