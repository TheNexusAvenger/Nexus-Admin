--[[
TheNexusAvenger

Registers commands on the server.
--]]
--!strict

local Registry = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("Registry"))
local Types = require(script.Parent.Parent:WaitForChild("Types"))

local ServerRegistry = {}
ServerRegistry.__index = ServerRegistry
setmetatable(ServerRegistry, Registry)



--[[
Creates the server registry.
--]]
function ServerRegistry.new(Cmdr: Types.Cmdr, Configuration: Types.Configuration, Authorization: Types.Authorization, Messages: Types.MessagesServer, Logs: Types.Logs, Time: Types.Time, Filter: Types.FilterServer, NexusAdminRemotes: Folder): Types.RegistryServer
    local self = Registry.new(Authorization, Configuration, Messages, Cmdr, NexusAdminRemotes) :: any
    setmetatable(self, ServerRegistry)
    self.ClientData = {}

    --Create the remote objects.
    local RegistryEvents = Instance.new("Folder")
    RegistryEvents.Name = "RegistryEvents"
    RegistryEvents.Parent = NexusAdminRemotes

    local GetRegisteredCommands = Instance.new("RemoteFunction")
    GetRegisteredCommands.Name = "GetRegisteredCommands"
    GetRegisteredCommands.Parent = RegistryEvents
    self.GetRegisteredCommands = GetRegisteredCommands

    local CommandRegistered = Instance.new("RemoteEvent")
    CommandRegistered.Name = "CommandRegistered"
    CommandRegistered.Parent = RegistryEvents
    self.CommandRegistered = CommandRegistered

    --Connect the remote objects.
    function GetRegisteredCommands.OnServerInvoke()
        return self.ClientData
    end

    --Register the BeforeRun hook for verifying admin levels and logging.
    self.Cmdr.Registry:RegisterHook("BeforeRun", function(CommandContext: Types.CmdrCommandContext): ()
        --Return if a result exists from the common function.
        local BeforeRunResult = self:PerformBeforeRun(CommandContext)
        if BeforeRunResult then
            return BeforeRunResult
        end

        --Log the command asynchronously.
        task.spawn(function()
            Logs:Add(CommandContext.Executor.Name.." ["..Time:GetTimeString().."]: "..Filter:FilterString(CommandContext.RawText,CommandContext.Executor))
        end)
        return nil
    end)

    --Return the object.
    return (self :: any) :: Types.RegistryServer
end

--[[
Loads a command.
--]]
function ServerRegistry:LoadCommand(CommandData: Types.NexusAdminCommandData): ()
    Registry.LoadCommand(self :: any, CommandData)

    --Add and send the command data.
    table.insert(self.ClientData, CommandData)
    self.CommandRegistered:FireAllClients(CommandData)

    --Register the command.
    local CmdrCommandData = self:GetReplicatableCmdrData(CommandData) :: Types.NexusAdminCommandData
    CmdrCommandData.Run = self:CreateRunMethod(CommandData)
    self.Cmdr.Registry:RegisterCommandObject(CmdrCommandData)

    --Load the command.
    if (CommandData :: any).OnCommandLoad then
        warn("OnCommandLoad (used in "..CmdrCommandData.Name..") is deprecated as of V.2.0.0. All commands are loaded as of V.2.0.0, so this is no longer needed.");
        (CommandData :: any).OnCommandLoad()
    end
end



return (ServerRegistry :: any) :: Types.RegistryServer