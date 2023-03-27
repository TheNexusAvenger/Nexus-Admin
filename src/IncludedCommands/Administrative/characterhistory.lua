--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local CLOSE_THRESHOLD = 0.1
local CHARACTER_HISTORY_MAX_ENTRIES = 1000
local TYPE_TO_COLOR = {
    Movement = Color3.fromRGB(0, 170, 255),
    NewCharacter = Color3.fromRGB(0, 255, 0),
    ServerTeleport = Color3.fromRGB(0, 0, 255),
    ClientTeleport = Color3.fromRGB(255, 0, 0),
}



local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

local Logs = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("Logs")) :: Types.Logs

return {
    Keyword = "characterhistory",
    Category = "Administrative",
    Description = "Displays the recent history of a player's location and some properties.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Player",
            Description = "Player to view the snapshot of. Multiple players is not supported.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApi)
        --Store the history of the local player.
        local CharacterLogs = Logs.new(CHARACTER_HISTORY_MAX_ENTRIES)
        task.spawn(function()
            --[[
            Adds a log entry.
            --]]
            local function AddLog(Type: string, Position: Vector3, Humanoid: Humanoid): ()
                --Return if the log is a duplicate.
                local CurrentLogs = CharacterLogs:GetLogs()
                local LastLog = CurrentLogs[1]
                local PreviousIsClose = LastLog and (LastLog.Position - Position).Magnitude < CLOSE_THRESHOLD
                if PreviousIsClose and Type == "Movement" then
                    return
                end

                --Add the entry.
                local Entry = {
                    Time = game.Workspace:GetServerTimeNow(),
                    Type = Type,
                    Position = Position,
                    Humanoid = {
                        WalkSpeed = Humanoid.WalkSpeed,
                        Health = Humanoid.Health,
                        MaxHealth = Humanoid.MaxHealth,
                    },
                }
                if Humanoid.UseJumpPower then
                    Entry.Humanoid.JumpPower = Humanoid.JumpPower
                else
                    Entry.Humanoid.JumpHeight = Humanoid.JumpHeight
                end
                CharacterLogs:Add(Entry)
            end

            --Start the loop.
            local LastCharacter: Model? = nil
            while true do
                task.wait(0.5)

                --Ignore if the character does not exist.
                local Character = Players.LocalPlayer.Character :: Model
                if not Character then continue end
                local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart
                if not Humanoid or not HumanoidRootPart then continue end
                
                if LastCharacter ~= Character then
                    --Connect the new character.
                    HumanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
                        AddLog("ClientTeleport", HumanoidRootPart.Position, Humanoid)
                    end)
                    AddLog("NewCharacter", HumanoidRootPart.Position, Humanoid)
                    LastCharacter = Character
                else
                    --Add the movement entry.
                    AddLog("Movement", HumanoidRootPart.Position, Humanoid)
                end
            end
        end);

        --Connect fetching the logs.
        (Api.EventContainer:WaitForChild("GetCharacterHistory") :: RemoteFunction).OnClientInvoke = function()
            local Entries = {}
            local CurrentEntries = CharacterLogs:GetLogs()
            for i = #CurrentEntries, 1, -1 do
                table.insert(Entries, CurrentEntries[i])
            end
            return Entries
        end
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local TeleportLogs = {} :: {[Player]: Types.Logs}
        Api.CommandData.TeleportLogs = TeleportLogs

        --[[
        Connects a character.
        --]]
        local function ConnectCharacter(Player: Player, Character: Model): ()
            if not Character then return end
            local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 60) :: BasePart
            if not HumanoidRootPart then return end
            HumanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
                if not TeleportLogs[Player] then return end
                TeleportLogs[Player]:Add(HumanoidRootPart.Position)
            end)
        end

        --[[
        Connects a player.
        --]]
        local function ConnectPlayer(Player: Player): ()
            TeleportLogs[Player] = Logs.new(CHARACTER_HISTORY_MAX_ENTRIES)
            Player.CharacterAppearanceLoaded:Connect(function(Character)
                ConnectCharacter(Player, Character)
            end)
            ConnectCharacter(Player, Player.Character :: Model)
        end

        --Connect players joining.
        Players.PlayerAdded:Connect(ConnectPlayer)
        for _, Player in Players:GetPlayers() do
            task.spawn(function()
                ConnectPlayer(Player)
            end)
        end
        
        --Connect players leaving.
        Players.PlayerRemoving:Connect(function(Player)
            TeleportLogs[Player] = nil
        end)

        --Create the remote function.
        local GetCharacterHistoryRemoteFunction = Instance.new("RemoteFunction")
        GetCharacterHistoryRemoteFunction.Name = "GetCharacterHistory"
        GetCharacterHistoryRemoteFunction.Parent = Api.EventContainer

        function GetCharacterHistoryRemoteFunction.OnServerInvoke(Player, TargetPlayer)
            if not TargetPlayer or not TargetPlayer.Parent then
                return nil
            elseif Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("Administrative", "characterhistory")) then
                local History = GetCharacterHistoryRemoteFunction:InvokeClient(TargetPlayer) :: {any}
                local TeleportLocations = TeleportLogs[TargetPlayer]:GetLogs()
                for _, Entry in History do
                    if Entry.Type ~= "ClientTeleport" then continue end
                    local IsClose = false
                    for _, Position in TeleportLocations do
                        if (Position - Entry.Position).Magnitude > CLOSE_THRESHOLD then continue end
                        IsClose = true
                        break
                    end
                    if not IsClose then continue end
                    Entry.Type = "ServerTeleport"
                end
                return History
            else
                return "Unauthorized"
            end
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, PlayersList: {Player})
        local Player = PlayersList[1]
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        local ResizableWindow = require(script.Parent.Parent.Parent:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("ResizableWindow")) :: any

        --Create the window.
        local CharacterHistoryScreenGui = Instance.new("ScreenGui")
        CharacterHistoryScreenGui.Name = "CharacterHistoryView"
        CharacterHistoryScreenGui.ResetOnSpawn = false
        CharacterHistoryScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

        local CurrentDisplayCenter: BasePart? = nil
        local CurrentInfoCenter: BasePart? = nil
        local Camera = Workspace.Camera
        local CameraViewportSize = Camera.ViewportSize
        local GetClientViewRemoteFunction = Api.EventContainer:WaitForChild("GetCharacterHistory") :: RemoteFunction
        local Window = ResizableWindow.new()
        Window.Title = "History - "..Player.DisplayName.." ("..Player.Name..")"

        local ScreenSizeText = Instance.new("TextLabel")
        ScreenSizeText.BackgroundTransparency = 1
        ScreenSizeText.Size = UDim2.new(0.95, 0, 1, -10)
        ScreenSizeText.Position = UDim2.new(0.025, 0, 0, 5)
        ScreenSizeText.Font = Enum.Font.SourceSans
        ScreenSizeText.TextColor3 = Color3.new(1, 1, 1)
        ScreenSizeText.TextStrokeColor3 = Color3.new(0, 0, 0)
        ScreenSizeText.TextStrokeTransparency = 0
        ScreenSizeText.TextSize = CameraViewportSize.Y * 0.5 * 0.045
        ScreenSizeText.TextXAlignment = Enum.TextXAlignment.Left
        ScreenSizeText.TextYAlignment = Enum.TextYAlignment.Top
        ScreenSizeText.Text = "Loading..."
        ScreenSizeText.Parent = Window.ContentsAdorn

        function Window:OnRefresh()
            --Get the screen data.
            ScreenSizeText.Text = "Loading..."
            if CurrentDisplayCenter then
                CurrentDisplayCenter:Destroy()
                CurrentDisplayCenter = nil
            end
            local CharacterHistory = GetClientViewRemoteFunction:InvokeServer(Player) :: {any}
            if not CharacterHistory then
                return
            end

            --Replace the display.
            local NewDisplayCenter = Instance.new("Part")
            NewDisplayCenter.Transparency = 1
            NewDisplayCenter.Anchored = true
            NewDisplayCenter.CanCollide = false
            NewDisplayCenter.Size = Vector3.zero
            NewDisplayCenter.CFrame = CFrame.identity
            NewDisplayCenter.Parent = CharacterHistoryScreenGui
            CurrentDisplayCenter = NewDisplayCenter

            local TypeCounts = {} :: {[string]: number}
            for i, Entry in CharacterHistory do
                --Create the pointer for the position.
                local Pointer = Instance.new("SphereHandleAdornment")
                Pointer.Color3 = TYPE_TO_COLOR[Entry.Type]
                Pointer.Transparency = 0.25
                Pointer.Radius = (Entry.Type == "Movement" and 0.5 or 1)
                Pointer.ZIndex = 0
                Pointer.AlwaysOnTop = true
                Pointer.Name = tostring(i)
                Pointer.CFrame = CFrame.new(Entry.Position)
                Pointer.Adornee = NewDisplayCenter
                Pointer.Parent = NewDisplayCenter
                if not TypeCounts[Entry.Type] then
                    TypeCounts[Entry.Type] = 0
                end
                TypeCounts[Entry.Type] += 1
                
                --Connect showing the details.
                Pointer.MouseEnter:Connect(function()
                    --Clear the existing details.
                    if CurrentInfoCenter then
                        CurrentInfoCenter:Destroy()
                        CurrentInfoCenter = nil
                    end

                    --Show the details.
                    local InfoCenter = Instance.new("Part")
                    InfoCenter.Transparency = 1
                    InfoCenter.Anchored = true
                    InfoCenter.CanCollide = false
                    InfoCenter.CanQuery = false
                    InfoCenter.CFrame = CFrame.new(Entry.Position)
                    InfoCenter.Size = Vector3.zero
                    InfoCenter.Parent = CharacterHistoryScreenGui
                    CurrentInfoCenter = InfoCenter

                    local Messsage = Entry.Type.."\n"..string.format("%.3f, %.3f, %.3f", Entry.Position.X, Entry.Position.Y, Entry.Position.Z)
                    local HumanoidEntries = 0
                    for Property, Value in Entry.Humanoid do
                        Messsage = Messsage.."\n"..Property..": "..tostring(Value)
                        HumanoidEntries += 1
                    end
                    
                    local BillboardGui = Instance.new("BillboardGui")
                    BillboardGui.AlwaysOnTop = true
                    BillboardGui.Size = UDim2.new(0, 300, 0, 24 * (2 + HumanoidEntries))
                    BillboardGui.Adornee = InfoCenter
                    BillboardGui.Parent = InfoCenter
                    
                    local Background = Instance.new("Frame")
                    Background.BackgroundTransparency = 0.5
                    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    Background.BorderSizePixel = 0
                    Background.Size = UDim2.new(1, 0, 1, 0)
                    Background.Parent = BillboardGui
                    
                    local BackgroundCorner = Instance.new("UICorner")
                    BackgroundCorner.CornerRadius = UDim.new(0, 8)
                    BackgroundCorner.Parent = Background

                    local TextLabel = Instance.new("TextLabel")
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.Size = UDim2.new(1, -6, 1, -6)
                    TextLabel.Position = UDim2.new(0, 3, 0, 3)
                    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    TextLabel.Text = Messsage
                    TextLabel.Font = Enum.Font.SourceSans
                    TextLabel.TextScaled = true
                    TextLabel.TextWrapped = true
                    TextLabel.Parent = Background
                end)
                Pointer.MouseLeave:Connect(function()
                    --Clear the details.
                    if CurrentInfoCenter then
                        CurrentInfoCenter:Destroy()
                        CurrentInfoCenter = nil
                    end
                end)
                
                --Create the line to the previous section.
                if i == 1 or Entry.Type == "NewCharacter" then continue end
                local LastEntry = CharacterHistory[i - 1]
                local Length = (LastEntry.Position - Entry.Position).Magnitude
                local Line = Instance.new("CylinderHandleAdornment")
                Line.Transparency = 0.25
                Line.Name = tostring(i - 1).."-"..tostring(i)
                Line.ZIndex = 0
                Line.AlwaysOnTop = true
                Line.Color3 = TYPE_TO_COLOR[Entry.Type]
                Line.Radius = 0.2
                Line.CFrame = CFrame.new(LastEntry.Position, Entry.Position) * CFrame.new(0, 0, -Length / 2)
                Line.Height = Length
                Line.Adornee = NewDisplayCenter
                Line.Parent = NewDisplayCenter
            end

            --Update the screen text.
            local Text =  "Total entries: "..tostring(#CharacterHistory)
            for Type, Value in TypeCounts do
                Text = Text.."\n"..Type..": "..tostring(Value)
            end
            ScreenSizeText.Text = Text
        end

        function Window:OnClose()
            if CurrentDisplayCenter then
                CurrentDisplayCenter:Destroy()
                CurrentDisplayCenter = nil
            end
            if CurrentInfoCenter then
                CurrentInfoCenter:Destroy()
                CurrentInfoCenter = nil
            end
            Window.WindowFrame:TweenPosition(UDim2.new(0, Window.WindowFrame.AbsolutePosition.X, 0, Camera.ViewportSize.Y), "Out", "Back", 0.5, false, function()
                Window:Destroy()
                CharacterHistoryScreenGui:Destroy()
            end)
        end

        --Show the window.
        Window.WindowFrame.Parent = CharacterHistoryScreenGui
        Window.WindowFrame.Size = UDim2.new(0, CameraViewportSize.Y * 0.3, 0, CameraViewportSize.Y * 0.175)
        Window.WindowFrame.Position = UDim2.new(0, (CameraViewportSize.X / 2) - (Window.WindowFrame.AbsoluteSize.X / 2), 0, CameraViewportSize.Y)
        Window.WindowFrame:TweenPosition(UDim2.new(0, (CameraViewportSize.X / 2) - (Window.WindowFrame.AbsoluteSize.X / 2), 0, CameraViewportSize.Y * 0.7), "Out", "Back", 0.5, false)
        Window:OnRefresh()
    end,
}