--[[
TheNexusAvenger

Stores a log of events.
--]]
--!strict

local NexusEvent = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("Event"):WaitForChild("NexusEvent"))
local Types = require(script.Parent.Parent:WaitForChild("Types"))

local Logs = {}
Logs.__index = Logs



--[[
Creates a logs instance.
--]]
function Logs.new(MaxLogs: number?): Types.Logs
    local self = {}
    setmetatable(self, Logs)

    self.MaxLogs = MaxLogs or 10000
    self.Logs = {}
    self.LogAdded = NexusEvent.new()
    return (self :: any) :: Types.Logs
end

--[[
Returns the logs.
--]]
function Logs:GetLogs(): {any}
    return self.Logs
end

--[[
Adds a log.
--]]
function Logs:Add(Log: any): ()
    table.insert(self.Logs, 1, Log)
    self.Logs[(self.MaxLogs :: number) + 1] = nil
    self.LogAdded:Fire(Log)
end

--[[
Destroys the logs.
--]]
function Logs:Destroy(): ()
    self.LogAdded:Disconnect()
end



return (Logs :: any) :: Types.Logs