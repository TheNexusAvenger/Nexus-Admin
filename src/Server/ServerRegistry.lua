--[[
TheNexusAvenger

Registers commands on the server.
--]]

local Registry = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("Registry"))

local ServerRegistry = Registry:Extend()
ServerRegistry:SetClassName("ServerRegistry")



--[[
Creates the server registry.
--]]
function ServerRegistry:__new(Cmdr,Authorization,Messages,NexusAdminRemotes)
    self:InitializeSuper(Authorization,Messages)
    
    self.ClientData = {}
    self.Cmdr = Cmdr

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
end

--[[
Loads a command.
--]]
function ServerRegistry:LoadCommand(CommandData)
    self.super:LoadCommand(CommandData)

    --Add and send the command data.
    table.insert(self.ClientData,CommandData)
    self.CommandRegistered:FireAllClients(CommandData)

    --Register the command.
    local CmdrCommandData = self:GetReplicatableCmdrData(CommandData)
    CmdrCommandData.Run = self:CreateRunMethod(CommandData)
    self.Cmdr.Registry:RegisterCommandObject(CmdrCommandData)

    --Load the command.
    if CommandData.OnCommandLoad then
        warn("OnCommandLoad (used in "..CmdrCommandData.Name..") is deprecated as of V.2.0.0. All commands are loaded as of V.2.0.0, so this is no longer needed.")
        CommandData.OnCommandLoad()
    end
end



return ServerRegistry