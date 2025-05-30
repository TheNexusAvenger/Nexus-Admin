--Implementation of a command.
--!strict

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

local Serialization = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusAdminClient"):WaitForChild("IncludedCommands"):WaitForChild("Resources"):WaitForChild("Serialization")) :: any

return {
    Keyword = "snapshot",
    Category = "Administrative",
    Description = "Displays the current ScreenGuis of a player. CoreGuis are not shown due to security permissions.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Player",
            Description = "Player to view the snapshot of. Multiple players is not supported.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApi)
        (Api.EventContainer:WaitForChild("GetClientViewRemoteFunction") :: RemoteFunction).OnClientInvoke = function()
            --Get the ScreenGuis.
            local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
            local SnapshotRootFolder = PlayerGui:FindFirstChild("NexusAdmin_Snapshots")
            local BaseScreenGuis = {}
            local ScreenGuis = {}
            for _, ScreenGui in PlayerGui:GetDescendants() do
                if ScreenGui:IsA("ScreenGui") and ScreenGui.Enabled and #ScreenGui:GetChildren() > 0 and (not SnapshotRootFolder or not ScreenGui:IsDescendantOf(SnapshotRootFolder)) then
                    table.insert(BaseScreenGuis, ScreenGui)
                end
            end
            for _, ScreenGui in BaseScreenGuis do
                local ContainedInScreenGui = false
                for _, OtherScreenGui in BaseScreenGuis do
                    if ScreenGui:IsDescendantOf(OtherScreenGui) then
                        ContainedInScreenGui = true
                        break
                    end
                end
                if not ContainedInScreenGui then
                    table.insert(ScreenGuis, ScreenGui)
                end
            end
    
            --Determine the screen resolution.
            local Resolution = Workspace.CurrentCamera.ViewportSize
            if #ScreenGuis > 0 then
                Resolution = ScreenGuis[1].AbsoluteSize
            end
    
            --Return the data.
            return {
                ScreenSizeX = Resolution.X,
                ScreenSizeY = Resolution.Y,
                ScreenGuis = Serialization:Serialize(ScreenGuis, function(Ins)
                    return Ins:IsA("GuiObject") and not Ins.Visible
                end),
            }
        end
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        --Create the remote function.
        local GetClientViewRemoteFunction = Instance.new("RemoteFunction")
        GetClientViewRemoteFunction.Name = "GetClientViewRemoteFunction"
        GetClientViewRemoteFunction.Parent = Api.EventContainer

        function GetClientViewRemoteFunction.OnServerInvoke(Player, TargetPlayer)
            Serialization:UpdateApiReference()
            if not TargetPlayer or not TargetPlayer.Parent then
                return nil
            elseif Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("Administrative", "snapshot")) then
                return GetClientViewRemoteFunction:InvokeClient(TargetPlayer)
            else
                return "Unauthorized"
            end
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, PlayersList: {Player})
        local Player = PlayersList[1]
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        --Determine the offset.
        local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local Offset = 0
        for _, Folder in PlayerGui:GetChildren() do
            local SnapshotBackground = Folder:FindFirstChild("SnapshotBackground")
            if Folder:IsA("Folder") and SnapshotBackground then
                Offset = math.max(Offset, SnapshotBackground.DisplayOrder)
            end
        end
        Offset = Offset + 1000

        --Create the containers.
        local SnapshotRootFolder = PlayerGui:FindFirstChild("NexusAdmin_Snapshots")
        if not SnapshotRootFolder then
            SnapshotRootFolder = Instance.new("Folder")
            SnapshotRootFolder.Name = "NexusAdmin_Snapshots"
            SnapshotRootFolder.Parent = PlayerGui
        end

        local SnapshotFolder = Instance.new("Folder")
        SnapshotFolder.Name = `Snapshot_{Player}`
        SnapshotFolder.Parent = SnapshotRootFolder

        local SnapshotBackground = Instance.new("ScreenGui")
        SnapshotBackground.Name = "SnapshotBackground"
        SnapshotBackground.DisplayOrder = Offset
        SnapshotBackground.Parent = SnapshotFolder

        local SnapshotBackgroundFrame = Instance.new("Frame")
        SnapshotBackgroundFrame.BackgroundTransparency = 0.75
        SnapshotBackgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        SnapshotBackgroundFrame.BorderSizePixel = 0
        SnapshotBackgroundFrame.Size = UDim2.new(1, 0, 1, 0)
        SnapshotBackgroundFrame.Parent = SnapshotBackground

        local SnapshotScreenGuisFolder = Instance.new("Folder")
        SnapshotScreenGuisFolder.Name = "ScreenGuis"
        SnapshotScreenGuisFolder.Parent = SnapshotFolder

        --Create the window.
        local Camera = Workspace.Camera
        local CameraViewportSize = Camera.ViewportSize
        local GetClientViewRemoteFunction = Api.EventContainer:WaitForChild("GetClientViewRemoteFunction") :: RemoteFunction
        local Window = Api.Window:CreateWindow(`Snapshot - {Player.DisplayName} ({Player.Name})`)
        Window:EnableResizing()

        local ScreenSizeText = Instance.new("TextLabel")
        ScreenSizeText.BackgroundTransparency = 1
        ScreenSizeText.Size = UDim2.new(0.95, 0, 1, -10)
        ScreenSizeText.Position = UDim2.new(0.025, 0, 0, 5)
        ScreenSizeText.Font = Enum.Font.SourceSans
        ScreenSizeText.TextColor3 = Color3.fromRGB(255, 255, 255)
        ScreenSizeText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        ScreenSizeText.TextStrokeTransparency = 0
        ScreenSizeText.TextSize = CameraViewportSize.Y * 0.5 * 0.045
        ScreenSizeText.TextXAlignment = Enum.TextXAlignment.Left
        ScreenSizeText.TextYAlignment = Enum.TextYAlignment.Top
        ScreenSizeText.Text = "Loading..."
        ScreenSizeText.Parent = Window.ContentsAdorn

        local function Refresh()
            --Get the screen data.
            ScreenSizeText.Text = "Loading..."
            local ScreenData = GetClientViewRemoteFunction:InvokeServer(Player)
            if not ScreenData then
                return
            end

            --Update the screen text.
            ScreenSizeText.Text = `Screen size X: {ScreenData.ScreenSizeX}\nScreen size Y: {ScreenData.ScreenSizeY}`

            --Show the ScreenGuis.
            SnapshotScreenGuisFolder:ClearAllChildren()
            for _, ScreenGui in Serialization:Deserialize(ScreenData.ScreenGuis) do
                ScreenGui.Parent = SnapshotScreenGuisFolder
                ScreenGui.DisplayOrder += (1000 + 1)
            end
        end

        Window:EnableRefreshing(Refresh)
        task.spawn(Refresh)

        Window:EnableClosing(function()
            SnapshotBackground:Destroy()
            SnapshotScreenGuisFolder:Destroy()
        end)

        --Show the window.
        Window:SetDisplayOrder(Offset + 900)
        Window:SetRelativeSize(0.3, 0.125)
        Window:Show(UDim2.new(0.5, 0, 0.8, 0), Vector2.new(0.5, 1), Enum.NormalId.Bottom)
    end,
}