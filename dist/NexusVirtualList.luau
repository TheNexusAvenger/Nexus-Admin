--Passthrough of Nexus Virtual List for Wally distribution.
--!strict

local NexusVirtualList = require(script.Parent.Parent.Parent.Parent:WaitForChild("NexusVirtualList"))

export type ListEntry<T> = NexusVirtualList.ListEntry<T>
export type ListEntryConstructor<T> = NexusVirtualList.ListEntryConstructor<T>
export type VirtualScrollList<T> = NexusVirtualList.VirtualScrollList<T>
export type AutoScrollingVirtualScrollList<T> = NexusVirtualList.AutoScrollingVirtualScrollList<T>

return NexusVirtualList