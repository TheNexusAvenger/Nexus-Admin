--[[
TheNexusAvenger

Manages fetching logs on the client.
--]]

local NexusObject = require(script.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))
local Logs = require(script.Parent:WaitForChild("Common"):WaitForChild("Logs"))

local ClientLogsRegistry = NexusObject:Extend()
ClientLogsRegistry:SetClassName("ClientLogRegistry")



--[[
Creates a client logs registry instance.
--]]
function ClientLogsRegistry:__new(NexusAdminRemotes)
    self:InitializeSuper()

    --Connect listening for new log entries.
    local LogsRegistryEvents = NexusAdminRemotes:WaitForChild("LogsRegistry")
    local LogAddedEvent = LogsRegistryEvents:WaitForChild("LogAdded")
    self.GetLogEntriesFunction = LogsRegistryEvents:WaitForChild("GetLogEntries")

    self.Logs = {}
    LogAddedEvent.OnClientEvent:Connect(function(LogName, Entry)
        self.Logs[LogName]:Add(Entry)
    end)
end

--[[
Registers a log that can be streamed.
--]]
function ClientLogsRegistry:RegisterLogs(LogName, Logs)
    if self.Logs[LogName] then
        error("Log already registered: "..tostring(LogName))
    end
    self.Logs[LogName] = Logs
end

--[[
Gets a registered log.
--]]
function ClientLogsRegistry:GetLogs(LogName)
    if not self.Logs[LogName] then
        local ExistingLogs, MaxLogs = self.GetLogEntriesFunction:InvokeServer(LogName)
        if typeof(ExistingLogs) == "string" then
            error("Unable to get registered log \""..tostring(LogName).."\": "..ExistingLogs)
        end

        local NewLogs = Logs.new(MaxLogs)
        NewLogs.Logs = ExistingLogs
        self.Logs[LogName] = NewLogs
    end
    return self.Logs[LogName]
end



return ClientLogsRegistry