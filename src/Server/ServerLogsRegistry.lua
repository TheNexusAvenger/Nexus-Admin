--[[
TheNexusAvenger

Manages logs that are streamed to clients on the server.
--]]

local Players = game:GetService("Players")

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))

local ServerLogsRegistry = NexusObject:Extend()
ServerLogsRegistry:SetClassName("ServerLogRegistry")



--[[
Creates a server logs registry instance.
--]]
function ServerLogsRegistry:__new(Authorization, NexusAdminRemotes)
    self:InitializeSuper()

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
    GetLogEntriesFunction.OnServerInvoke = function(Player, LogName)
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
    Players.PlayerRemoving:Connect(function(Player)
        for _, LogData in self.Logs do
            for i = 1, #LogData.ListeningPlayers do
                if LogData.ListeningPlayers[i] == Player then
                    table.remove(LogData.ListeningPlayers, i)
                    break
                end
            end
        end
    end)
end

--[[
Registers a log that can be streamed.
--]]
function ServerLogsRegistry:RegisterLogs(LogName, Logs, MinimumAdminLevel)
    --Store the log.
    if self.Logs[LogName] then
        error("Log already registered: "..tostring(LogName))
    end
    self.Logs[LogName] = {
        Logs = Logs,
        MinimumAdminLevel = MinimumAdminLevel,
        ListeningPlayers = {},
    }

    --Connect entries being stored.
    Logs.LogAdded:Connect(function(LogEntry)
        for _, Player in self.Logs[LogName].ListeningPlayers do
            self.LogAddedEvent:FireClient(Player, LogName, LogEntry)
        end
    end)
end



return ServerLogsRegistry