--Manages logs that are streamed to clients on the server.
--!strict

local Players = game:GetService("Players")

local Types = require(script.Parent.Parent:WaitForChild("Types"))

local ServerLogsRegistry = {}
ServerLogsRegistry.__index = ServerLogsRegistry

type LogDataEntry = {
    MinimumAdminLevel: number,
    ListeningPlayers: {Player},
    Logs: Types.Logs,
}
export type ServerLogsRegistry = {
    GetLogEntriesFunction: RemoteFunction,
    LogAddedEvent: RemoteEvent,
    Logs: {[string]: LogDataEntry},
} & typeof(setmetatable({}, ServerLogsRegistry))



--[[
Creates a server logs registry instance.
--]]
function ServerLogsRegistry.new(Authorization: Types.Authorization, NexusAdminRemotes: Folder): ServerLogsRegistry
    local self = setmetatable({}, ServerLogsRegistry) :: ServerLogsRegistry

    --Create the remote objects.
    local LogsRegistryEvents = Instance.new("Folder")
    LogsRegistryEvents.Name = "LogsRegistry"
    LogsRegistryEvents.Parent = NexusAdminRemotes

    local GetLogEntriesFunction = Instance.new("RemoteFunction")
    GetLogEntriesFunction.Name = "GetLogEntries"
    GetLogEntriesFunction.Parent = LogsRegistryEvents
    self.GetLogEntriesFunction = GetLogEntriesFunction

    local LogAddedEvent = Instance.new("RemoteEvent")
    LogAddedEvent.Name = "LogAdded"
    LogAddedEvent.Parent = LogsRegistryEvents
    self.LogAddedEvent = LogAddedEvent

    --Connect getting logs.
    self.Logs = {}
    GetLogEntriesFunction.OnServerInvoke = function(Player: Player, LogName: string): ({any} | string, number?)
        --Get the log.
        local LogData = self.Logs[LogName]
        if not LogData then
            return "Log not found"
        end

        --Check if the player is authorized.
        if LogData.MinimumAdminLevel and not Authorization:IsPlayerAuthorized(Player, LogData.MinimumAdminLevel) then
            return "Unauthorized"
        end

        --Add the players to the listeners.
        local PlayerListening = false
        for _, OtherPlayer in LogData.ListeningPlayers do
            if Player ~= OtherPlayer then continue end
            PlayerListening = true
            break
        end
        if not PlayerListening then
            table.insert(LogData.ListeningPlayers, Player)
        end

        --Return the log entires.
        return LogData.Logs:GetLogs(), LogData.Logs.MaxLogs
    end

    --Connect players leaving.
    Players.PlayerRemoving:Connect(function(Player: Player)
        for _, LogData in self.Logs do
            for i = 1, #LogData.ListeningPlayers do
                if LogData.ListeningPlayers[i] == Player then
                    table.remove(LogData.ListeningPlayers, i)
                    break
                end
            end
        end
    end)

    --Return the object.
    return self
end

--[[
Registers a log that can be streamed.
--]]
function ServerLogsRegistry.RegisterLogs(self: ServerLogsRegistry, LogName: string, Logs: Types.Logs, MinimumAdminLevel: number): ()
    --Store the log.
    if self.Logs[LogName] then
        error(`Log already registered: {LogName}`)
    end
    self.Logs[LogName] = {
        Logs = Logs,
        MinimumAdminLevel = MinimumAdminLevel,
        ListeningPlayers = {},
    }

    --Connect entries being stored.
    Logs.LogAdded:Connect(function(LogEntry)
        for _, Player in (self.Logs :: {[string]: LogDataEntry})[LogName].ListeningPlayers do
            self.LogAddedEvent:FireClient(Player, LogName, LogEntry)
        end
    end)
end

--[[
Gets a registered log.
--]]
function ServerLogsRegistry.GetLogs(self: ServerLogsRegistry, LogName: string): Types.Logs
    if not self.Logs[LogName] then
        error(`Unable to get registered log "{LogName}": Log not found.`)
    end
    return self.Logs[LogName].Logs
end



return ServerLogsRegistry