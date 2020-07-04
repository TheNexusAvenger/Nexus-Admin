--[[
TheNexusAvenger

Stores a log of events.
--]]

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))

local Logs = NexusObject:Extend()
Logs:SetClassName("Logs")



--[[
Creates a logs instance.
--]]
function Logs:__new(MaxLogs)
    self:InitializeSuper()
    
    self.MaxLogs = MaxLogs or 500
    self.Logs = {}
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
    table.insert(self.Logs,1,Log)
    self.Logs[self.MaxLogs + 1] = nil
end



return Logs