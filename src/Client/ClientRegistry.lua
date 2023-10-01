--[[
TheNexusAvenger

Registers commands on the client.
--]]
--!strict

local Types = require(script.Parent:WaitForChild("Types"))
local Registry = require(script.Parent:WaitForChild("Common"):WaitForChild("Registry")) :: Types.Registry

local ClientRegistry = {}
ClientRegistry.__index = ClientRegistry
setmetatable(ClientRegistry, Registry)



--[[
Creates the client registry.
--]]
function ClientRegistry.new(Authorization: Types.Authorization, Configuration: Types.Configuration, Messages: Types.MessagesClient,Cmdr: Types.Cmdr, NexusAdminRemotes: Folder): Types.Registry
    local self = Registry.new(Authorization, Configuration, Messages, Cmdr, NexusAdminRemotes)
    setmetatable(self, ClientRegistry)

    --Set up the events.
    local RegistryEvents = NexusAdminRemotes:WaitForChild("RegistryEvents")
    local GetRegisteredCommands = RegistryEvents:WaitForChild("GetRegisteredCommands");
    (self :: any).GetRegisteredCommands = GetRegisteredCommands
    local CommandRegistered = RegistryEvents:WaitForChild("CommandRegistered");
    (CommandRegistered :: RemoteEvent).OnClientEvent:Connect(function(Data: Types.NexusAdminCommandData): ()
        (self :: any):LoadCommand(Data)
    end);

    --Register the BeforeRun hook for verifying admin levels.
    ((self :: any).Cmdr :: Types.Cmdr).Registry:RegisterHook("BeforeRun", function(CommandContext): string?
        --Return if a result exists from the common function.
        local BeforeRunResult = (self :: any):PerformBeforeRun(CommandContext)
        if BeforeRunResult then
            return BeforeRunResult
        end
        return nil
    end)
    return (self :: any) :: Types.Registry
end

--[[
Loads a command.
--]]
function ClientRegistry:LoadCommand(CommandData: Types.NexusAdminCommandData): ()
    Registry.LoadCommand(self :: any, CommandData)
    
    --Register the command.
    local CmdrCommandData = self:GetReplicatableCmdrData(CommandData)
    local ExistingCommand = self.Cmdr.Registry.Commands[CmdrCommandData.Name]
    if (CommandData :: any).OnInvoke or CommandData.Run then
        CmdrCommandData.ClientRun = self:CreateRunMethod(CommandData)
    elseif ExistingCommand then
        CmdrCommandData.ClientRun = ExistingCommand.ClientRun
    end

    -- Force arguments lost during invocation to be included on the client. Extremely shallow.
	if ExistingCommand then
		for index,arg in ipairs(ExistingCommand.Args) do
			if typeof(CmdrCommandData.Args[index]) ~= typeof(arg) then
				table.insert(CmdrCommandData.Args,index,arg)
			end
		end
	end
    
    self.Cmdr.Registry:RegisterCommandObject(CmdrCommandData)
end

--[[
Loads the current commands from the server.
--]]
function ClientRegistry:LoadServerCommands(): ()
    for _, Command in self.GetRegisteredCommands:InvokeServer() do
        self:LoadCommand(Command)
    end
end



return (ClientRegistry :: any) :: Types.Registry
