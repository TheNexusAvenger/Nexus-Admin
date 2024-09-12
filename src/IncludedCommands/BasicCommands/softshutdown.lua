--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))



--[[
Creates a GUI for the soft shutdown.
--]]
local function CreateSoftShutdownGui(Source: {Source: string, Name: string?, Reason: string?}?): (ScreenGui, Frame)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SoftShutdownGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 100

    --Create background to cover behind top bar.
    local BackgroundFrame = Instance.new("Frame")
    BackgroundFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    BackgroundFrame.BorderColor3 = Color3.new(0, 0, 0)
    BackgroundFrame.BorderSizePixel = 100
    BackgroundFrame.Position = UDim2.new(-0.5, 0, -0.5, 0)
    BackgroundFrame.Size = UDim2.new(2, 0, 2, 0)
    BackgroundFrame.ZIndex = 10
    BackgroundFrame.Parent = ScreenGui

    local TextAdornFrame = Instance.new("Frame")
    TextAdornFrame.BackgroundTransparency = 1
    TextAdornFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
    TextAdornFrame.Size = UDim2.new(0.5, 0, 0.5, 0)
    TextAdornFrame.ZIndex = 10
    TextAdornFrame.Parent = BackgroundFrame

    --[[
    Creates a text label.
    --]]
    local function CreateTextLabel(Properties)
        local TextLabel = Instance.new("TextLabel")
        TextLabel.BackgroundTransparency = 1
        TextLabel.ZIndex = 10
        TextLabel.Font = Enum.Font.SourceSansBold
        TextLabel.TextScaled = true
        TextLabel.TextColor3 = Color3.new(1, 1, 1)
        TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        TextLabel.TextStrokeTransparency = 0
        TextLabel.Parent = TextAdornFrame
        for Key, Value in Properties do
            (TextLabel :: any)[Key] = Value
        end
    end

    --Create the main text.
    CreateTextLabel({
        Size = UDim2.new(0.5, 0, 0.08, 0),
        Position = UDim2.new(0.25, 0, 0.44, 0),
        Text = "This server is restarting",
    })
    CreateTextLabel({
        Size = UDim2.new(0.5, 0, 0.06, 0),
        Position = UDim2.new(0.25, 0, 0.525, 0),
        Text = "Please wait",
    })
    CreateTextLabel({
        Size = UDim2.new(0.5, 0, 0.05, 0),
        Position = UDim2.new(0.01, 0, 0.94, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "Nexus Admin",
    })

    --Display the source.
    if Source then
        --Determine the message.
        local SourceText = "Soft shutdown source is unknown"
        if Source.Source == "BindToClose" then
            if Source.Reason then
                SourceText = `BindToClose was invoked by the server ({Source.Reason})`
            else
                SourceText = "BindToClose was invoked by the server. Shutting down may have been requested remotely"
            end
        elseif Source.Source == "Player" then
            SourceText = `The soft shutdown command was invoked by {Source.Name}`
        end

        --Create the text.
        CreateTextLabel({
            Size = UDim2.new(0.5, 0, 0.04, 0),
            Position = UDim2.new(0.99, 0, 0.92, 0),
            AnchorPoint = Vector2.new(1, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = SourceText,
        })
        CreateTextLabel({
            Size = UDim2.new(0.5, 0, 0.025, 0),
            Position = UDim2.new(0.99, 0, 0.96, 0),
            AnchorPoint = Vector2.new(1, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = "The soft shutdown source is only shown to admins",
        })
    end

    --Return the ScreenGui and the background.
    return ScreenGui, BackgroundFrame
end



return {
    Keyword = "softshutdown",
    Category = "BasicCommands",
    Description = "Restarts the server by teleporting everyone out and back in to a new server. Invoking in-game works best if there is only 1 active server.",
    ClientLoad = function(Api: Types.NexusAdminApi)
        --Teleport the player back if they are in a temporary server.
        local TeleportData = TeleportService:GetLocalPlayerTeleportData()
        if TeleportData and TeleportData.IsNexusAdminTemporaryServer then
            local TeleportGui = TeleportService:GetArrivingTeleportGui() or CreateSoftShutdownGui(TeleportData.ShutdownSource)
            TeleportGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
            StarterGui:SetCore("TopbarEnabled",false)
            StarterGui:SetCoreGuiEnabled("All",false)
            task.wait(5)
            TeleportService:Teleport(TeleportData.PlaceId, Players.LocalPlayer, nil, TeleportGui)
        end

        --Connect the remote event.
        (Api.EventContainer:WaitForChild("StartSoftShutdown") :: RemoteEvent).OnClientEvent:Connect(function(ShutdownSource)
            --Create the Gui and have it semi-transparent for 1 second.
            local TeleportGui,Background = CreateSoftShutdownGui(ShutdownSource)
            Background.BackgroundTransparency = 0.5
            TeleportGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
            task.wait(1)
            
            --Tween the transparency to 0.
            TweenService:Create(Background, TweenInfo.new(2), {BackgroundTransparency = 0}):Play()
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local StartSoftShutdownRemoteEvent = IncludedCommandUtil:CreateRemote("RemoteEvent", "StartSoftShutdown") :: RemoteEvent

        --Create the soft shutdown object.
        local SoftShutdown = {}
        Api.CommandData.SoftShutdown = SoftShutdown

        function SoftShutdown:SplitPlayersForSources(Players: {Player}): ({Player}, {Player})
            local SourcePlayers = {}
            local SourcelessPlayers = {}
            for _, Player in Players do
                if Api.Authorization:IsPlayerAuthorized(Player, 0) then
                    table.insert(SourcePlayers, Player)
                else
                    table.insert(SourcelessPlayers, Player)
                end
            end
            return SourcePlayers, SourcelessPlayers
        end

        function SoftShutdown:PerformSoftShutdown(ShutdownSource)
            --Return if there is no players.
            if #Players:GetPlayers() == 0 then
                return
            end
        
            --Return if the server instance is offline.
            if game.JobId == "" then
                return
            end
        
            --Send the shutdown message.
            local PlaceId = game.PlaceId
            local ReservedServerCode = TeleportService:ReserveServer(PlaceId)
            local SourcePlayers, SourcelessPlayers = self:SplitPlayersForSources(Players:GetPlayers())
            for _, Player in SourcePlayers do
                StartSoftShutdownRemoteEvent:FireClient(Player, ShutdownSource)
            end
            for _, Player in SourcelessPlayers do
                StartSoftShutdownRemoteEvent:FireClient(Player)
            end
        
            --Create the teleport GUIs.
            local TeleportedPlayers = {}
            local SourceScreenGui = CreateSoftShutdownGui(ShutdownSource)
            local SourcelessScreenGui = CreateSoftShutdownGui()
            local function TeleportPlayers(Players)
                local SourcePlayers, SourcelessPlayers = self:SplitPlayersForSources(Players)
                for _, Player in Players do
                    TeleportedPlayers[Player.UserId] = true
                end
                if #SourcePlayers > 0 then
                    TeleportService:TeleportToPrivateServer(PlaceId, ReservedServerCode, SourcePlayers, nil, {IsNexusAdminTemporaryServer=true, PlaceId=PlaceId, ShutdownSource=ShutdownSource}, SourceScreenGui)
                end
                if #SourcelessPlayers > 0 then
                    TeleportService:TeleportToPrivateServer(PlaceId, ReservedServerCode, SourcelessPlayers, nil, {IsNexusAdminTemporaryServer=true, PlaceId=PlaceId}, SourcelessScreenGui)
                end
            end
        
            --Teleport players and try to keep the server alive until all players leave.
            task.wait(2)
            TeleportPlayers(Players:GetPlayers())
            Players.PlayerAdded:Connect(function(Player)
                --Kick the player if they were already teleported before.
                --This attempts to mitigate servers not shutting down when the command is used.
                if TeleportedPlayers[Player.UserId] then
                    Player:Kick("You were accidentally teleported back or rejoined to a server that was shutting down. You have been kicked to prevent being stuck teleporting.")
                    return
                end
        
                --Teleport the player.
                TeleportPlayers({Player})
            end)
            while #Players:GetPlayers() > 0 do task.wait() end
        end

        --Connect the server closing.
        Api.FeatureFlags:AddFeatureFlag("PerformSoftShutdownOnClose", true)
        game:BindToClose(function(Reason)
            if Api.FeatureFlags:GetFeatureFlag("PerformSoftShutdownOnClose") then
                SoftShutdown:PerformSoftShutdown({
                    Source = "BindToClose",
                    Reason = Reason and Reason.Name,
                })
            end
        end)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext): string?
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Return if the server instance is offline.
        if game.JobId == "" then
            return "Soft shutdown can not be used when in Roblox Studio."
        end

        --Start the soft shutdown.
        Api.CommandData.SoftShutdown:PerformSoftShutdown({
            Source = "Player",
            Name = CommandContext.Executor.DisplayName.." ("..CommandContext.Executor.Name..")",
        })
        return nil
    end,
}