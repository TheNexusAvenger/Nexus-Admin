--[[
TheNexusAvenger

Loads Nexus Admin on the client.
--]]

local NexusAdminClient = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusAdminClient"))
if not NexusAdminClient.FeatureFlags:GetFeatureFlag("UseCmdrCommandBar") then
    NexusAdminClient.Cmdr:SetEnabled(false)
end
NexusAdminClient.Cmdr:SetActivationKeys({Enum.KeyCode.BackSlash})
NexusAdminClient.Registry:LoadServerCommands()
NexusAdminClient:LoadIncludedCommands()