--Passthrough of Nexus Feature Flags for Wally distribution.
--!strict

local NexusFeatureFlags = require(script.Parent.Parent.Parent.Parent:WaitForChild("NexusFeatureFlags"))

export type NexusFeatureFlagsSource = NexusFeatureFlags.NexusFeatureFlagsSource

return NexusFeatureFlags