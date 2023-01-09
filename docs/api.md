# Nexus Admin API
## Types
Nexus Admin is intended to be loaded when the game
starts. This means no types are shown in Studio.
To get around this, it is recommended to have
a copy of the [Types](https://github.com/TheNexusAvenger/Nexus-Admin/blob/typing-refactor/src/Types.lua)
script. There are no dependencies and can be
stored anywhere in the game.

## Fetching The API
Nexus Admin's API is fetched differently on the client
and the server.
```lua
local NexusAdminTypes = require(...)

--Server
local NexusAdminApi = require(game:GetService("ServerScriptService"):WaitForChild("NexusAdmin")) :: NexusAdminTypes.NexusAdminApiServer
while not NexusAdminApi:GetAdminLoaded() do
    task.wait()
end

--Client
local NexusAdminApi = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusAdminClient")) :: NexusAdminTypes.NexusAdminApiClient
```

## API Properties
- `AdminItemContainer: Folder`: Folder in `Workspace`
  that will be cleared with the `clear` command.
- `Cmdr: Cmdr`: Raw Cmdr API used by Nexus Admin.
- `CmdrVersion: string`: String-based version of Cmdr
  that Nexus Admin is using.
- `CommandData: {[any]: any}`: Table intended for
  commands to store persistent data or expose APIs. While
  it is used for included commands, no APIs are exposed
  that are guarenteed to be maintained long-term.
- `EventContainer: Folder`: Folder intended for storing
  `RemoteEvent`s and `RemoteFunction`s.
- `Version: string`: String-based version of Nexus Admin.
- `VersionNumberId: number`: Major and minor version
  of Nexus Admin in the form of a number. Intended to
  check compatibility of versions.

## API Modules
### `Authorization`
#### `Authorization.AdminLevelChanged: NexusEvent<Player>`
Event fired when the admin level of a player changes.

#### `Authorization:GetAdminLevel(Player: Player): number`
Returns the admin level for a player.

#### `Authorization:IsPlayerAuthorized(Player: Player, AdminLevel: number): boolean`
Returns if a player is authorized for the admin level specified.

#### `Authorization:SetAdminLevel(Player: Player, AdminLevel: number): ()`
Sets the admin level for a player.

#### `Authorization:YieldForAdminLevel(Player: Player): number`
Wait for the admin level to be initialized for a player and
returns the admin level. If already initialized, the admin level
will be returned immediately.

### `Configuration`
#### `Configuration.Version: string`
String-based version of Nexus Admin.

#### `Configuration.VersionNumberId: number`
Major and minor version of Nexus Admin in the form of a
number. Intended to check compatibility of versions.

#### `Configuration.CmdrVersion: string`
String-based version of Cmdr that Nexus Admin is using.

#### `Configuration.RawConfiguration: {[string]: any}`
Raw configuration passed in from the loader.

#### `Configuration.CommandPrefix: string`
Default prefix to use with chat comamnds.

#### `Configuration.ActivationKeys: {Enum.KeyCode}`
Keys used to open the command bar.

#### `Configuration.DefaultAdminLevel: number`
Default admin level that will be given to players
when the join.

#### `Configuration.AdministrativeLevel: number`
Default admin level required for "Administrative" commands.

#### `Configuration.BuildUtilityLevel: number`
Default admin level required for "Build Utility" commands.

#### `Configuration.BasicCommandsLevel: number`
Default admin level required for "Basic Commands" commands.

#### `Configuration.UsefulFunCommandsLevel: number`
Default admin level required for "Useful Fun Commands" commands.

#### `Configuration.FunCommandsLevel: number`
Default admin level required for "Fun Commands" commands.

#### `Configuration.PersistentCommandsLevel: number`
Default admin level required for "Persistent Commands" commands.

#### `Configuration.Admins: {[number]: number}`
Table with the keys being the user ids to and the values being
the admin level for the user.

#### `Configuration.AdminNames: {[number]: string}`
Table with the keys being the admin level and the value being
the name of the admin leve.

It is possible for admins levels to exist with no name.
It is recommended to the highest admin level name that does
not go above the given admin level.

#### `Configuration.GroupAdminLevels: {[number]: {[number]: number}}`
Table for storing the admin levels of group members. The keys
refer to the group id with the values being a table with the keys
being the role id and the value being the admin level.

#### `Configuration.BannedUsers: {[number]: string | boolean}`
Table for storing the banned users, with the keys being the user
id and either a ban message for `true` if no ban message should
be shown.

#### `Configuration.CommandLevelOverrides: {[string]: {[string]: number}}`
Table for storing overrides to command levels. `Configuration:GetCommandAdminLevel(Category, Command)`
should be used for reading it.

#### `Configuration.FeatureFlagOverrides: {[string]: any}`
Feature flag overrides defined by the configuration.

#### `Configuration:GetRaw(): {[string]: any}`
Return the Raw configuration passed in from the loader.

#### `Configuration:GetCommandAdminLevel(Category: string, Command: string): number`
Returns the admin level to use for an integrated command.

### `Executor`
#### `Executor:ExecuteCommand(Command: string, ReferencePlayer: Player?, Data: any?): string`
Executes a command directly though Cmdr without any Nexus Admin
chat prefixes.

#### `Executor:ExecuteCommandWithPrefix(Command: string, ReferencePlayer: Player?, Data: any?): string`
Executes a command only if it has a chat prefix in Nexus Admin.

#### `Executor:ExecuteCommandWithOrWithoutPrefix(Command: string, ReferencePlayer: Player?, Data: any?): string`
Executes a command that may or may not have a prefix in Nexus Admin.

### `FeatureFlags`
See [Nexus Feature Flag's docs](https://github.com/TheNexusAvenger/Nexus-Feature-Flags/blob/master/docs/usage.md).

### `Filter`
#### `Filter:EscapeRichText(String: string): string`
Escapes a string for use with rich text.

#### `Filter:FilterString(String: string, PlayerFrom: Player, PlayerTo: Player?): string` *(Server-Only)*
Filters a string from a player. A destination player can be optionally
specified to filter for that specific player.

### `Filter:FilterStringForPlayers(String: string, PlayerFrom: Player, PlayersTo: {Player}) -> {[Player]: string}` *(Server-Only)*
Filters a string individually for a set of players. The returned
table is the strings to use for the target players.

### `Logs` *(Server-Only)*
`Logs` is a singleton instance of `NexusAdminTypes.Logs`
that stores the history of commands being ran. For creating
a new instance of `Logs`, require the module instead.

```lua
local NexusAdminTypes = require(...)
local Logs = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusAdminClient"):WaitForChid("Common"):WaitForChild("Logs")) :: NexusAdminTypes.Logs

local MyLogs = Logs.new()
```

#### `Logs.MaxLogs: number`
Maximum number of entries the logs can store.

#### `Logs.LogAdded: NexusEvent<any>`
Event for a log entry being added.

#### `Logs:GetLogs(): {any}`
Returns the current entriese of the logs.

### `Logs:Add(Log: any): ()`
Adds a log entry.

### `Logs:Destroy(): ()`
Disconnects all events for the logs.

### `LogsRegistry`
To synchronize `Logs` from the server to the client automatically,
the `LogsRegistry` can be used to store logs.

#### `LogsRegistry:GetLogs(LogName: string): Logs`
Returns the logs for a given name. The first time this is called on
the client will yield to fetch the initial entries. An error will
be thrown on the client if the admin level of the player is not
high enough for the logs.

#### `LogsRegistry:RegisterLogs(LogName: string, Logs: Logs, MinimumAdminLevel: number): ()`
Registers logs to be replicated to clients. A minimum admin level
must be given to restrict which players can read the logs. An error
will be thrown is duplicate log names are used.

### `Messages`
#### `Messages:DisplayHint(Message: string, DisplayTime: number?): ()` *Client-Only*
Displays a message at the top of the screen for the local player.

#### `Messages:DisplayHint(Player: Player, Message: string, DisplayTime: number?): ()` *Server-Only*
Displays a message at the top of the screen for the specified player.

#### `Messages:DisplayMessage(TopText: string, Message: string, DisplayTime: number?): ()` *Client-Only*
Displays a full-screen message to the local player.

#### `Messages:DisplayMessage(Player: Player, TopText: string, Message: string, DisplayTime: number?): ()` *Server-Only*
Displays a full-screen message to the specified player.

#### `Messages:DisplayNotification(TopText: string, Message: string, DisplayTime: number?): ()` *Client-Only*
Displays a slide-in notification to the local player.

#### `Messages:DisplayNotification(TopText: string, Message: string, DisplayTime: number?): ()` *Server-Only*
Displays a slide-in notification to the specified player.

### `Types`
`Types` is a table used for Cmdr types to expose
additional APIs. Anything can add to it.

#### `Types.NexusAdminPlayers:RegisterPatternShortHand(Name:  Name: string | {string}, Callback: (Text: string, Executor: Player, Players: {Player}) -> ({Player})): ()`
Registers a short hand or list of short hands for parsing
player arguments. In the callback to parse players, `Text`
is the input text to parse, `Executor` is the player executing
the command, and `Players` is the players to filter though.
For the short hand to apply, it must match the pattern of
the short hand.

#### `Types.NexusAdminPlayers:RegisterShortHand(Name:  Name: string | {string}, Callback: (Text: string, Executor: Player, Players: {Player}) -> ({Player})): ()`
Registers a short hand or list of short hands for parsing
player arguments. In the callback to parse players, `Text`
is the input text to parse, `Executor` is the player executing
the command, and `Players` is the players to filter though.
For the short hand to apply, it must match the text exactly
ignoring case.

### `Registry`
#### `Registry:AddEnumType(Name: string, Options: {string}): ()`
Adds an enum type for commands to use where the string is the
name of the type and the options are the values the enum can have.
A version of that enum with the name will be registered as a type
to return a single value while the name with an `"s"` appended
will be registered to return multiple values.

`AddEnumType` can be re-ran with the same name to update the values.

#### `Registry:LoadCommand(CommandData: NexusAdminCommandData): ()`
Registers a command in Nexus Admin. See [creating-commands](creating-commands.md)
for more.

### `Replicator` *(Server-Only)*
#### `Replicator:GiveScriptToPlayer(Player: Player, Script: BaseScript): ()`
Gives a script to a specified player.

#### `Replicator:GiveStarterScript(Script: BaseScript): ()`
Gives a script to all players and new players.

### `Time`
#### `Time:GetTimeString(Time: number?): string`
Returns the current or specified time to a formatted string.