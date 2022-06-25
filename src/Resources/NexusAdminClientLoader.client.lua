--[[
TheNexusAvenger

Loads Nexus Admin on the client.
--]]

local NexusAdminClient = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusAdminClient"))
NexusAdminClient.Cmdr:SetActivationKeys({Enum.KeyCode.Apostrophe})
NexusAdminClient.Registry:LoadServerCommands()
NexusAdminClient:LoadIncludedCommands()
