--[[
TheNexusAvenger

Passthrough for types for development.
For backwards compatibility, the client modules can't be moved.
--]]
--!strict

local Types = require(script.Parent.Parent:WaitForChild("Types"))

export type Cmdr = Types.Cmdr
export type NexusAdminCommandData = Types.NexusAdminCommandData
export type Authorization = Types.Authorization
export type Configuration = Types.Configuration
export type MessagesClient = Types.MessagesClient
export type Registry = Types.Registry

return true