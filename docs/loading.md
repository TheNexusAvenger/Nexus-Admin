# Loading
Nexus Admin is intended to be loaded using
the loader script from the Roblox toolbox.
In the case this isn't an option, a custom
loader can be set up.

On the server, the following is required:
```lua
--Require Nexus Admin (not the MainModule)
local NexusAdmin = require(game.ServerScriptServicee.MainModule.NexusAdmin)

--Initializes the server API (this is required).
--The Configuration is a table defined in
--the load and is optional.
NexusAdmin:Load(Configuration)

--Loads the included commands (not running will
--make it so no commands are loaded).
NexusAdmin:LoadIncludedCommands()

--Creates the client loader. If this is not run,
--a client loader will need to be made.
NexusAdmin:LoadClientLoader()
```

If `NexusAdmin:LoadClientLoader()` isn't
invoked, a client loader must also be provided
as a `LocalScript`:
```lua
--Require Nexus Admin. It will always be in this location after loading on the server.
local NexusAdminClient = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusAdminClient"))

--Register the F2 key for opening the Cmdr console (optional).
NexusAdminClient.Cmdr:SetActivationKeys({Enum.KeyCode.F2})

--Load the commands already registered on the server (recommended,
--for disabling loading of the included commands, do not remove this).
NexusAdminClient.Registry:LoadServerCommands()

--Load the included client-side commands (optional).
NexusAdminClient:LoadIncludedCommands()
```