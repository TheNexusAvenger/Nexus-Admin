--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local CreateTeleportScreen = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("SoftShutdownGuiCreator"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("softshutdown","BasicCommands","Restarts the server by teleporting everyone out and back in to a new server. Invoking in-game works best if there is only 1 active server.")
    
    --Set up the remote object.
    local StartSoftShutdownRemoteEvent = Instance.new("RemoteEvent")
    StartSoftShutdownRemoteEvent.Name = "StartSoftShutdown"
    StartSoftShutdownRemoteEvent.Parent = self.API.EventContainer
    self.StartSoftShutdownRemoteEvent = StartSoftShutdownRemoteEvent

    --Connect the server closing.
    self.API.FeatureFlags:AddFeatureFlag("PerformSoftShutdownOnClose",true)
    game:BindToClose(function()
        if self.API.FeatureFlags:GetFeatureFlag("PerformSoftShutdownOnClose") then
            self:PerformSoftShutdown()
        end
    end)
end

--[[
Performs a soft shutdown.
--]]
function Command:PerformSoftShutdown()
    --Return if there is no players.
    if #self.Players:GetPlayers() == 0 then
        return
    end

    --Return if the server instance is offline.
    if game.JobId == "" then
        return
    end

    --Send the shutdown message.
    local PlaceId = game.PlaceId
	local ReservedServerCode = self.TeleportService:ReserveServer(PlaceId)
    self.StartSoftShutdownRemoteEvent:FireAllClients()
    
    --Create the teleport GUI.
    local ScreenGui = CreateTeleportScreen()
    local function TeleportPlayers(Players)
        self.TeleportService:TeleportToPrivateServer(PlaceId,ReservedServerCode,Players,nil,{IsNexusAdminTemporaryServer=true,PlaceId=PlaceId},ScreenGui)
    end

    --Teleport players and try to keep the server alive until all players leave.
    wait(2)
    TeleportPlayers(self.Players:GetPlayers())
    self.Players.PlayerAdded:Connect(function(Player)
        TeleportPlayers({Player})
    end)
    while #self.Players:GetPlayers() > 0 do wait() end
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
	self.super:Run(CommandContext)
    
    --Start the soft shutdown.
    self:PerformSoftShutdown()
end



return Command