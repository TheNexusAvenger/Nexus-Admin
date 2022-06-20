--[[
TheNexusAvenger

Implementation of a command.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local SoftShutdownGuiCreator = script.Parent.Parent:WaitForChild("Resources"):WaitForChild("SoftShutdownGuiCreator")
local CreateTeleportScreen = require(SoftShutdownGuiCreator)
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("softshutdown", "BasicCommands", "Restarts the server by teleporting everyone out and back in to a new server. Invoking in-game works best if there is only 1 active server.")

    --Copy the GUI creator.
    SoftShutdownGuiCreator:Clone().Parent = ReplicatedStorage:WaitForChild("NexusAdminClient"):WaitForChild("IncludedCommands"):WaitForChild("Resources")

    --Set up the remote object.
    local StartSoftShutdownRemoteEvent = Instance.new("RemoteEvent")
    StartSoftShutdownRemoteEvent.Name = "StartSoftShutdown"
    StartSoftShutdownRemoteEvent.Parent = self.API.EventContainer
    self.StartSoftShutdownRemoteEvent = StartSoftShutdownRemoteEvent

    --Connect the server closing.
    self.API.FeatureFlags:AddFeatureFlag("PerformSoftShutdownOnClose", true)
    game:BindToClose(function()
        if self.API.FeatureFlags:GetFeatureFlag("PerformSoftShutdownOnClose") then
            self:PerformSoftShutdown({
                Source = "BindToClose"
            })
        end
    end)
end

--[[
Splits the players to those who should and shouldn't see the sources of shutdowns.
--]]
function Command:SplitPlayersForSources(Players)
    local SourcePlayers = {}
    local SourcelessPlayers = {}
    for _, Player in pairs(Players) do
        if self.API.Authorization:IsPlayerAuthorized(Player, 0) then
            table.insert(SourcePlayers, Player)
        else
            table.insert(SourcelessPlayers, Player)
        end
    end
    return SourcePlayers, SourcelessPlayers
end

--[[
Performs a soft shutdown.
--]]
function Command:PerformSoftShutdown(ShutdownSource)
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
    local SourcePlayers, SourcelessPlayers = self:SplitPlayersForSources(self.Players:GetPlayers())
    for _, Player in pairs(SourcePlayers) do
        self.StartSoftShutdownRemoteEvent:FireClient(Player, ShutdownSource)
    end
    for _, Player in pairs(SourcelessPlayers) do
        self.StartSoftShutdownRemoteEvent:FireClient(Player)
    end

    --Create the teleport GUIs.
    local TeleportedPlayers = {}
    local SourceScreenGui = CreateTeleportScreen()
    local SourcelessScreenGui = CreateTeleportScreen(ShutdownSource)
    local function TeleportPlayers(Players)
        local SourcePlayers, SourcelessPlayers = self:SplitPlayersForSources(Players)
        for _, Player in pairs(Players) do
            TeleportedPlayers[Player.UserId] = true
        end
        if #SourcePlayers > 0 then
            self.TeleportService:TeleportToPrivateServer(PlaceId, ReservedServerCode, SourcePlayers, nil, {IsNexusAdminTemporaryServer=true, PlaceId=PlaceId}, SourceScreenGui)
        end
        if #SourcelessPlayers > 0 then
            self.TeleportService:TeleportToPrivateServer(PlaceId, ReservedServerCode, SourcelessPlayers, nil, {IsNexusAdminTemporaryServer=true, PlaceId=PlaceId}, SourcelessScreenGui)
        end
    end

    --Teleport players and try to keep the server alive until all players leave.
    task.wait(2)
    TeleportPlayers(self.Players:GetPlayers())
    self.Players.PlayerAdded:Connect(function(Player)
        --Kick the player if they were already teleported before.
        --This attempts to mitigate servers not shutting down when the command is used.
        if TeleportedPlayers[Player.UserId] then
            Player:Kick("You were accidentally teleported back or rejoined to a server that was shutting down. You have been kicked to prevent being stuck teleporting.")
            return
        end

        --Teleport the player.
        TeleportPlayers({Player})
    end)
    while #self.Players:GetPlayers() > 0 do task.wait() end
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)

    --Start the soft shutdown.
    self:PerformSoftShutdown({
        Source = "Player",
        Name = CommandContext.Executor.Name.." ("..CommandContext.Executor.DisplayName..")",
    })
end



return Command