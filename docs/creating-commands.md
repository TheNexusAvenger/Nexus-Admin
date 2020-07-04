# Creating Commands

The intended method for registering commands is 
using tables of data. This can be done using
Nexus Admin's structure or Cmdr's structure.
You can mix-and-match between them assuming
there is no overlap of the data that is populated.
Nexus Admin's method mainly exist for backwards compatibility
with old versions.

## Nexus Admin Method
Nexus Admin's data structure supports the following elements:<br>
- `string | List<string> Keyword` - Keyword or keywords for the command.<br>
- `string | List<string> Prefix (optional)` - Prefix that must be before the command when executing from the chat.
- `string Category (optional)` - Category for the command. Mainly used for organization when displaying commands.<br>
- `string Description (optional)` - Description for the command. Mainly used for organization when displaying commands.<br>
- `number AdminLevel (optional)` - Admin level required to run the command. Be aware anyone can run a command if the admin level is not defined.<br>
- `List<`[`CommandArgument`](https://eryn.io/Cmdr/api/Registry.html#commandargument)`> Arguments (optional)` - Arguments used to run the command.<br>
- `function Run (optional)` - Runs the command.

The `Run` method is called with 2 parameters: The reference
to the command object and a [`CommandContext`](https://eryn.io/Cmdr/api/CommandContext.html#commandcontext).
Additional parameters are passed for each argument specified with
`Args` or `Arguments`. The examples above show this.

```lua
--Get the Nexus Admin API.
--Use a ModuleScript and parent this to the server loaded.
local NexusAdminAPI = require(game:GetService("ServerScriptService"):WaitForChild("NexusAdmin"))

--For the client, use:
--Use a local script and parent this to anywhere that runs player scripts, or use a ModuleScript required by a LocalScript.
--local NexusAdminAPI = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusAdminClient"))

--Create the command data.
local CommandData = {
	Keyword = "test", --Could use Keyword = {"test1","test2"} for multiple names.
	Prefix = NexusAdminAPI.Configuration.CommandPrefix, --Could use {NexusAdminAPI.Configuration.CommandPrefix,"!"} for multiple prefixes. Recommended to get the prefix from the configuration for consistency.
	Category = "TestCommands",
	Description = "My first test command!",
	AdminLevel = 2,
	Arguments = {
		{
			Type = "nexusAdminPlayers", --See below for nexusAdminPlayers vs players
			Name = "Players",
			Description = "Players execute on.",
		},
		{
			Type = "string",
			Name = "Message",
            Description = "Message to use.",
		},
	},
	Run = function(self,CommandContext,Players,Message)
		print("Raw command: "..CommandContext.RawText)
		print("Players: "..#Players)
		print("Message: "..Message)
	end,
}	
	
--Load the command.
NexusAdminAPI.Registry:LoadCommand(CommandData)

--Return true to make the ModuleScript not fail to load.
return true
```

## Cmdr Method
Any command passed into Nexus Admin's registry to load
has to be parsed to Cmdr's structure. Cmdr [`CommandDefinition`s](https://eryn.io/Cmdr/api/Registry.html#commanddefinition)
can also be passed into the registry. If there are considerations
of moving to Cmdr in the future instead of Nexus Admin,
Cmdr's structure should be used to minimize the time
converting code. `Prefix` and `AdminLevel` from the
Nexus Admin method can also be included for Nexus Admin.

```lua
--Get the Nexus Admin API.
--Use a ModuleScript and parent this to the server loaded.
local NexusAdminAPI = require(game:GetService("ServerScriptService"):WaitForChild("NexusAdmin"))

--For the client, use:
--Use a local script and parent this to anywhere that runs player scripts, or use a ModuleScript required by a LocalScript.
--local NexusAdminAPI = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusAdminClient"))

--Create the command data.
local CommandData = {
	Name = "test",
	Aliases = {"test1","test2"},
	Description = "My first test command!",
	Group = "TestCommands",
	Args = {
		{
			Type = "nexusAdminPlayers", --See below for nexusAdminPlayers vs players
			Name = "Players",
			Description = "Players execute on.",
		},
		{
			Type = "string",
			Name = "Message",
            Description = "Message to use.",
		},
	},
	Run = function(self,CommandContext,Players,Message)
		print("Raw command: "..CommandContext.RawText)
		print("Players: "..#Players)
		print("Message: "..Message)
	end,
	
	--Optional for Nexus Admin.
	Prefix = NexusAdminAPI.Configuration.CommandPrefix, --Could use {NexusAdminAPI.Configuration.CommandPrefix,"!"} for multiple prefixes. Recommended to get the prefix from the configuration for consistency.
	AdminLevel = 2,
}	
	
--Load the command.
NexusAdminAPI.Registry:LoadCommand(CommandData)

--Return true to make the ModuleScript not fail to load.
return true
```

## Custom type: `nexusAdminPlayers`
The `players` type in Cmdr has several limitations that made it
not ideal, including:<br>
- Shorthands (like `me`,`admins`) aren't extendable, preventing custom ones like `admins` and `nonadmins` from being used.<br>
- Teams and players can't be mixed (ex: `:god me,%green,%blue`).<br>
- `random` was rejected from being implemented. Those using old versions would have to get used to `?`.

`nexusAdminPlayers` can be used in place of `players` in any of the
arguments for handling players while still providing proper parsing
and auto-complete. For specific integrations, custom shorthands can
be added.