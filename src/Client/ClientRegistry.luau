--Registers commands on the client.
--!strict

local Types = require(script.Parent:WaitForChild("Types"))
local Registry = require(script.Parent:WaitForChild("Common"):WaitForChild("Registry")) :: Types.Registry

local ClientRegistry = {}
ClientRegistry.__index = ClientRegistry
setmetatable(ClientRegistry, Registry)

export type ClientRegistry = {
    GetRegisteredCommands: RemoteFunction,
    Cmdr: Types.Cmdr,
} & typeof(setmetatable({}, ClientRegistry)) & Types.Registry



--[[
Creates the client registry.
--]]
function ClientRegistry.new(Authorization: Types.Authorization, Configuration: Types.Configuration, Messages: Types.MessagesClient, Cmdr: Types.Cmdr, NexusAdminRemotes: Folder): ClientRegistry
    local self = setmetatable(Registry.new(Authorization, Configuration, Messages, Cmdr, NexusAdminRemotes), ClientRegistry) :: ClientRegistry

    --Set up the events.
    local RegistryEvents = NexusAdminRemotes:WaitForChild("RegistryEvents")
    local GetRegisteredCommands = RegistryEvents:WaitForChild("GetRegisteredCommands") :: RemoteFunction
    self.GetRegisteredCommands = GetRegisteredCommands
    local CommandRegistered = RegistryEvents:WaitForChild("CommandRegistered") :: RemoteEvent
    CommandRegistered.OnClientEvent:Connect(function(Data: Types.NexusAdminCommandData): ()
        self:LoadCommand(Data)
    end)

    --Register the BeforeRun hook for verifying admin levels.
    self.Cmdr.Registry:RegisterHook("BeforeRun", function(CommandContext): string?
        --Return if a result exists from the common function.
        local BeforeRunResult = self:PerformBeforeRun(CommandContext)
        if BeforeRunResult then
            return BeforeRunResult
        end
        return nil
    end)
    return self
end

--[[
Loads a command.
--]]
function ClientRegistry.LoadCommand(self: ClientRegistry, CommandData: Types.NexusAdminCommandData): ()
    Registry.LoadCommand(self :: any, CommandData)
    
    --Register the command.
    local CmdrCommandData = self:GetReplicatableCmdrData(CommandData)
    local ExistingCommand = self.Cmdr.Registry.Commands[CmdrCommandData.Name]
    if (CommandData :: any).OnInvoke or CommandData.Run then
        CmdrCommandData.ClientRun = self:CreateRunMethod(CommandData)
    elseif ExistingCommand then
        CmdrCommandData.ClientRun = ExistingCommand.ClientRun
    end

    --Force arguments lost during invocation to be included on the client. Extremely shallow.
    if ExistingCommand then
        for i, Argument in ExistingCommand.Args do
            if CmdrCommandData.Args[i] == nil and typeof(Argument) == "function" then
                table.insert(CmdrCommandData.Args, i, Argument)
            end
        end
    end
    
    self.Cmdr.Registry:RegisterCommandObject(CmdrCommandData)
end

--[[
Loads the current commands from the server.
--]]
function ClientRegistry.LoadServerCommands(self: ClientRegistry): ()
    for _, Command in self.GetRegisteredCommands:InvokeServer() do
        self:LoadCommand(Command)
    end
end



return ClientRegistry
