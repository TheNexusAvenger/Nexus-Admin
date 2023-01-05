--[[
TheNexusAvenger

Manages fetching logs on the client.
--]]
--!strict

local Types = require(script.Parent:WaitForChild("Types"))
local Logs = require(script.Parent:WaitForChild("Common"):WaitForChild("Logs")) :: Types.Logs

local ClientLogsRegistry = {}
ClientLogsRegistry.__index = ClientLogsRegistry



--[[
Creates a client logs registry instance.
--]]
function ClientLogsRegistry.new(NexusAdminRemotes: Folder): Types.LogsRegistryClient
    local self = {}
    setmetatable(self, ClientLogsRegistry)

    --Connect listening for new log entries.
    local LogsRegistryEvents = NexusAdminRemotes:WaitForChild("LogsRegistry")
    local LogAddedEvent = LogsRegistryEvents:WaitForChild("LogAdded") :: RemoteEvent
    self.GetLogEntriesFunction = LogsRegistryEvents:WaitForChild("GetLogEntries")

    self.Logs = {}
    LogAddedEvent.OnClientEvent:Connect(function(LogName, Entry)
        self.Logs[LogName]:Add(Entry)
    end)

    --Return the object.
    return (self :: any) :: Types.LogsRegistryClient
end

--[[
Registers a log that can be streamed.
--]]
function ClientLogsRegistry:RegisterLogs(LogName: string, Logs: Types.Logs): ()
    if self.Logs[LogName] then
        error("Log already registered: "..tostring(LogName))
    end
    self.Logs[LogName] = Logs
end

--[[
Gets a registered log.
--]]
function ClientLogsRegistry:GetLogs(LogName: string): Types.Logs
    if not self.Logs[LogName] then
        local ExistingLogs, MaxLogs = self.GetLogEntriesFunction:InvokeServer(LogName)
        if typeof(ExistingLogs) == "string" then
            error("Unable to get registered log \""..tostring(LogName).."\": "..ExistingLogs)
        end

        local NewLogs = Logs.new(MaxLogs) :: {Logs: {any}} & Types.Logs
        NewLogs.Logs = ExistingLogs
        self.Logs[LogName] = NewLogs
    end
    return self.Logs[LogName]
end



return ClientLogsRegistry