--[[
TheNexusAvenger

Passthrough for types for development.
For backwards compatibility, the client modules can't be moved.
--]]
--!strict

local Types = require(script.Parent.Parent:WaitForChild("Types"))

export type Configuration = Types.Configuration
export type Authorization = Types.Authorization

return true