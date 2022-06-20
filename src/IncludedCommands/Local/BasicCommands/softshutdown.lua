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
    
    --Teleport the player back if they are in a temporary server.
    local TeleportData = self.TeleportService:GetLocalPlayerTeleportData()
    if TeleportData and TeleportData.IsNexusAdminTemporaryServer then
        local TeleportGui = self.TeleportService:GetArrivingTeleportGui() or CreateTeleportScreen()
        TeleportGui.Parent = self.Players.LocalPlayer:WaitForChild("PlayerGui")
        self.StarterGui:SetCore("TopbarEnabled",false)
        self.StarterGui:SetCoreGuiEnabled("All",false)
        wait(5)
        self.TeleportService:Teleport(TeleportData.PlaceId,self.Players.LocalPlayer,nil,TeleportGui)
    end

    --Connect the remote event.
    self.API.EventContainer:WaitForChild("StartSoftShutdown").OnClientEvent:Connect(function(ShutdownSource)
        --Create the Gui and have it semi-transparent for 1 second.
        local TeleportGui,Background = CreateTeleportScreen(ShutdownSource)
        Background.BackgroundTransparency = 0.5
        TeleportGui.Parent = self.Players.LocalPlayer:WaitForChild("PlayerGui")
        wait(1)
        
        --Tween the transparency to 0.
        self.TweenService:Create(Background,TweenInfo.new(2),{BackgroundTransparency = 0}):Play()
    end)
end



return Command