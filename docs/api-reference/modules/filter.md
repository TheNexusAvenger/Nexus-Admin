# Filter
Filters strings to comply with Roblox's filtering rules.<br>
Exists only on the server.

## `string Filter:FilterString(string String,Player PlayerFrom,Player? PlayerTo)`
Filters a string for a user.

## `table<Player,string> Filter:FilterStringForPlayers(string String,Player PlayerFrom,List<Player> PlayersTo)`
Filters a string for a set of users.
Returns a map of the players to their filtered string.