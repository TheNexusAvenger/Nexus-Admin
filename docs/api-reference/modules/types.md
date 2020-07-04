# Types
Additional APIs for extending the Nexus Admin-specific types.<br>
Exists on the server and client.

## `Types.NexusAdminPlayers`
Type that allows specifying a list of players
with shorthands and other selectors.

### `void Types.NexusAdminPlayers:RegisterShortHand(string Name,function<string,Player> Callback)`
Registers a shorthand that matches a specific string
(ignoring case). If a match is found, the callback
will be invoked with the message and calling player
and expect a list of players back. Additional or missing
characters, as well as patterns, will not run the callback.

### `void Types.NexusAdminPlayers:RegisterPatternShortHand(string Name,function<string,Player> Callback)`
Registers a shorthand that matches a pattern (including case).
If a match is found in the pattern, the callback
will be invoked with the message and calling player
and expect a list of players back.