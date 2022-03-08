# Types
Additional APIs for extending the Nexus Admin-specific types.<br>
Exists on the server and client.

## `Types.NexusAdminPlayers`
Type that allows specifying a list of players
with shorthands and other selectors.

### `void Types.NexusAdminPlayers:RegisterShortHand(string Name,function<string,Player,List<Players>> Callback)`
Registers a shorthand that matches a specific string
(ignoring case). If a match is found, the callback
will be invoked with the message, calling player,
and list of players that match any existing filters.
This list should be used over `Players:GetPlayers()`.
The callback should return a list of the players that
match the shorthand. Additional or missing
characters, as well as patterns, will not run the callback.

### `void Types.NexusAdminPlayers:RegisterPatternShortHand(string Name,function<string,Player,List<Players>> Callback)`
Registers a shorthand that matches a pattern (including case).
If a match is found in the pattern, the callback
will be invoked with the message, calling player,
and list of players that match any existing filters.
This list should be used over `Players:GetPlayers()`.
The callback should return a list of the players that
match the shorthand.