--[[
TheNexusAvenger

Loads Nexus Admin on the client.
--]]

local NexusAdminClient = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusAdminClient"))
NexusAdminClient.Cmdr:SetActivationKeys({Enum.KeyCode.BackSlash})
NexusAdminClient.Registry:LoadServerCommands()
NexusAdminClient:LoadIncludedCommands()
