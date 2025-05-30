--Stores a log of events.
--!strict

local NexusInstance = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))

local TypedEvent = NexusInstance.TypedEvent

local Logs = {}
Logs.__index = Logs

export type Logs = {
    MaxLogs: number,
    Logs: {any},
    LogAdded: NexusInstance.TypedEvent<any>,
} & typeof(setmetatable({}, Logs))



--[[
Creates a logs instance.
--]]
function Logs.new(MaxLogs: number?): Logs
    return setmetatable({
        MaxLogs = MaxLogs or 10000,
        Logs = {},
        LogAdded = TypedEvent.new() :: any,
    }, Logs) :: Logs
end

--[[
Returns the logs.
--]]
function Logs.GetLogs(self: Logs): {any}
    return self.Logs
end

--[[
Adds a log.
--]]
function Logs.Add(self: Logs, Log: any): ()
    table.insert(self.Logs, 1, Log)
    self.Logs[(self.MaxLogs :: number) + 1] = nil
    self.LogAdded:Fire(Log)
end

--[[
Destroys the logs.
--]]
function Logs.Destroy(self: Logs): ()
    self.LogAdded:Destroy()
end



return Logs