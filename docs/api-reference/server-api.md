# Server API

## Getting Server API
The server API can be fetched using `require(game:GetService("ServerScriptService"):WaitForChild("NexusAdmin"))`. The API can be called in a server script, but it is recommended
to be put in a `ModuleScript` and parent it to the loader. This
guarentees the API is loaded before using.

## Server API Components

### Modules:
[`ServerAPI.Authorization`](modules/authorization.md)<br>
[`ServerAPI.Cmdr`](https://eryn.io/Cmdr/api/Cmdr.html)<br>
[`ServerAPI.Configuration`](modules/configuration.md)<br>
[`ServerAPI.Executor`](modules/executor.md)<br>
[`ServerAPI.FeatureFlags`](https://github.com/TheNexusAvenger/Nexus-Feature-Flags/blob/master/docs/usage.md)<br>
[`ServerAPI.Filter`](modules/filter.md)<br>
[`ServerAPI.Logs`](modules/logs.md)<br>
[`ServerAPI.Messages`](modules/servermessages.md)<br>
[`ServerAPI.Registry`](modules/registry.md)<br>
[`ServerAPI.Replicator`](modules/replicator.md)<br>
[`ServerAPI.Time`](modules/time.md)<br>
[`ServerAPI.Types`](modules/types.md)<br>

### `Folder ServerAPI.EventContainer`
Container in `ReplicatedStorage` for storing remote events.

### `Folder ServerAPI.AdminItemContainer`
Container in `Workspace` for models used in Nexus Admin.

### `boolean ServerAPI:GetAdminLoaded()`
Returns if Nexus Admin is loaded.