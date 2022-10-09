# LogsRegistry
Stores logs that can be fetched on the client or
server by name.

## `Log LogsRegistry:GetLogs(string LogName)`
Returns the logs that are registered. Throws an
error if the log does not exist or if it isn't
allowed to be accessed (client only).

## `void LogsRegistry:RegisterLogs(LogName, Logs, MinimumAdminLevel)`
Registers a log with a given name. On the server,
`MinimumAdminLevel` can be specified to prevent
unauthorized players from accessing logs they shouldn't
be able to read. On the client, `MinimumAdminLevel`
is ignored.