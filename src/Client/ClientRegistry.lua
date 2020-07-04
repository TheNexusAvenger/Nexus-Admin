--[[
TheNexusAvenger

Registers commands on the client.
--]]

local Registry = require(script.Parent:WaitForChild("Common"):WaitForChild("Registry"))

local ClientRegistry = Registry:Extend()
ClientRegistry:SetClassName("ClientRegistry")



--[[
Creates the client registry.
--]]
function ClientRegistry:__new(Cmdr,Authorization,Messages,NexusAdminRemotes)
    self:InitializeSuper(Authorization,Messages)

    self.Cmdr = Cmdr

    --Set up the events.
    local RegistryEvents = NexusAdminRemotes:WaitForChild("RegistryEvents")
    local GetRegisteredCommands = RegistryEvents:WaitForChild("GetRegisteredCommands")
    self.GetRegisteredCommands = GetRegisteredCommands
    local CommandRegistered = RegistryEvents:WaitForChild("CommandRegistered")
    CommandRegistered.OnClientEvent:Connect(function(Data)
        self:LoadCommand(Data)
    end)
end

--[[
Loads a command.
--]]
function ClientRegistry:LoadCommand(CommandData)
    self.super:LoadCommand(CommandData)
    
    --Register the command.
    local CmdrCommandData = self:GetReplicatableCmdrData(CommandData)
	local ExistingCommand = self.Cmdr.Registry.Commands[CmdrCommandData.Name]
    if CommandData.OnInvoke or CommandData.Run then
        CmdrCommandData.ClientRun = self:CreateRunMethod(CommandData)
	elseif ExistingCommand then
		CmdrCommandData.ClientRun = ExistingCommand.ClientRun
    end
    self.Cmdr.Registry:RegisterCommandObject(CmdrCommandData)
end

--[[
Loads the current commands from the server.
--]]
function ClientRegistry:LoadServerCommands()
    for _,Command in pairs(self.GetRegisteredCommands:InvokeServer()) do
		self:LoadCommand(Command)
	end
end



return ClientRegistry