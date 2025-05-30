--Passthrough of Nexus Data Store for Wally distribution.
--!strict

local NexusDataStore = require(script.Parent.Parent.Parent.Parent:WaitForChild("NexusDataStore"))

export type LocalSaveData = NexusDataStore.LocalSaveData
export type SaveData = NexusDataStore.SaveData
export type NexusDataStore = NexusDataStore.NexusDataStore

return NexusDataStore