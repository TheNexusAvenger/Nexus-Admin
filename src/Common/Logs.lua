--[[
TheNexusAvenger

Stores a log of events.
--]]

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))
local NexusEvent = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("Event"):WaitForChild("NexusEvent"))

local Logs = NexusObject:Extend()
Logs:SetClassName("Logs")



--[[
Creates a logs instance.
--]]
function Logs:__new(MaxLogs)
    self:InitializeSuper()

    self.MaxLogs = MaxLogs or 10000
    self.Logs = {}
    self.LogAdded = NexusEvent.new()
end

--[[
Returns the logs.
--]]
function Logs:GetLogs()
    return self.Logs
end

--[[
Adds a log.
--]]
function Logs:Add(Log)
    table.insert(self.Logs, 1, Log)
    self.Logs[self.MaxLogs + 1] = nil
    self.LogAdded:Fire(Log)
end

--[[
Destroys the logs.
--]]
function Logs:Destroy()
    self.LogAdded:Disconnect()
end



return Logs