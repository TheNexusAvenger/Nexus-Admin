# Client API

## Getting Client API
The client API can be fetched using `require(game:GetService("ReplicatedStorage"):WaitForChild("NexusAdminClient"))`. The API can be called in a LocalScript. Unlike the
server, the API can be used at any point since a configuration doesn't need to
load first from another script. The server configuration will already
be initialized by the time the client connects.

## Client API Components

### Modules:
[`ClientAPI.Authorization`](modules/authorization.md)<br>
[`ClientAPI.Cmdr`](https://eryn.io/Cmdr/api/Cmdr.html)<br>
[`ClientAPI.Configuration`](modules/configuration.md)<br>
[`ClientAPI.Executor`](modules/executor.md)<br>
[`ClientAPI.FeatureFlags`](modules/featureflags.md)<br>
[`ClientAPI.Gui`](modules/gui.md)<br>
[`ClientAPI.Messages`](modules/clientmessages.md)<br>
[`ClientAPI.Registry`](modules/registry.md)<br>
[`ClientAPI.Time`](modules/time.md)<br>
[`ClientAPI.Types`](modules/types.md)<br>

### `Folder ClientAPI.EventContainer`
Container in `ReplicatedStorage` for storing remote events.

### `Folder ClientAPI.AdminItemContainer`
Container in `Workspace` for models used in Nexus Admin.