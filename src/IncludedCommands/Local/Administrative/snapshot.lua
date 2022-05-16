--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Serialization = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("Serialization"))
local ResizableWindow = require(script.Parent.Parent.Parent:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("ResizableWindow"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("snapshot","Administrative","Displays the current ScreenGuis of a player. CoreGuis are not shown due to security permissions.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Player",
            Description = "Player to view the snapshot of. Multiple players is not supported.",
        },
    }

    --Connect the remote function.
    self.API.EventContainer:WaitForChild("GetClientViewRemoteFunction").OnClientInvoke = function()
        --Get the ScreenGuis.
        local PlayerGui = self.Players.LocalPlayer:WaitForChild("PlayerGui")
        local SnapshotRootFolder = PlayerGui:FindFirstChild("NexusAdmin_Snapshots")
        local BaseScreenGuis = {}
        local ScreenGuis = {}
        for _, ScreenGui in pairs(PlayerGui:GetDescendants()) do
            if ScreenGui:IsA("ScreenGui") and ScreenGui.Enabled and #ScreenGui:GetChildren() > 0 and (not SnapshotRootFolder or not ScreenGui:IsDescendantOf(SnapshotRootFolder)) then
                table.insert(BaseScreenGuis, ScreenGui)
            end
        end
        for _, ScreenGui in pairs(BaseScreenGuis) do
            local ContainedInScreenGui = false
            for _, OtherScreenGui in pairs(BaseScreenGuis) do
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
        local Resolution = self.Workspace.CurrentCamera.ViewportSize
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
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext, Players)
    self.super:Run(CommandContext)
    local Player = Players[1]

    --Determine the offset.
    local PlayerGui = self.Players.LocalPlayer:WaitForChild("PlayerGui")
    local Offset = 0
    for _, Folder in pairs(PlayerGui:GetChildren()) do
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
    SnapshotFolder.Name = "Snapshot_"..tostring(Player)
    SnapshotFolder.Parent = SnapshotRootFolder

    local SnapshotBackground = Instance.new("ScreenGui")
    SnapshotBackground.Name = "SnapshotBackground"
    SnapshotBackground.DisplayOrder = Offset
    SnapshotBackground.Parent = SnapshotFolder

    local SnapshotBackgroundWindow = Instance.new("ScreenGui")
    SnapshotBackgroundWindow.Name = "SnapshotBackgroundWindow"
    SnapshotBackgroundWindow.DisplayOrder = Offset + 900
    SnapshotBackgroundWindow.Parent = SnapshotFolder

    local SnapshotBackgroundFrame = Instance.new("Frame")
    SnapshotBackgroundFrame.BackgroundTransparency = 0.75
    SnapshotBackgroundFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    SnapshotBackgroundFrame.BorderSizePixel = 0
    SnapshotBackgroundFrame.Size = UDim2.new(1, 0, 1, 0)
    SnapshotBackgroundFrame.Parent = SnapshotBackground

    local SnapshotScreenGuisFolder = Instance.new("Folder")
    SnapshotScreenGuisFolder.Name = "ScreenGuis"
    SnapshotScreenGuisFolder.Parent = SnapshotFolder

    --Create the window.
    local Camera = self.Workspace.Camera
    local CameraViewportSize = Camera.ViewportSize
    local GetClientViewRemoteFunction = self.API.EventContainer:WaitForChild("GetClientViewRemoteFunction")
    local Window = ResizableWindow.new()
    Window.Title = "Snapshot - "..Player.DisplayName.." ("..Player.Name..")"

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
    ScreenSizeText.Text = ""
    ScreenSizeText.Parent = Window.ContentsAdorn

    function Window:OnRefresh()
        --Get the screen data.
        local ScreenData = GetClientViewRemoteFunction:InvokeServer(Player)
        if not ScreenData then
            return
        end

        --Update the screen text.
        ScreenSizeText.Text = "Screen size X: "..tostring(ScreenData.ScreenSizeX).."\nScreen size Y: "..tostring(ScreenData.ScreenSizeY)

        --Show the ScreenGuis.
        SnapshotScreenGuisFolder:ClearAllChildren()
        for _, ScreenGui in pairs(Serialization:Deserialize(ScreenData.ScreenGuis)) do
            ScreenGui.Parent = SnapshotScreenGuisFolder
            ScreenGui.DisplayOrder += (1000 + 1)
        end
    end

    function Window:OnClose()
        SnapshotBackground:Destroy()
        SnapshotScreenGuisFolder:Destroy()
        Window.WindowFrame:TweenPosition(UDim2.new(0, Window.WindowFrame.AbsolutePosition.X, 0, Camera.ViewportSize.Y), "Out", "Back", 0.5, false, function()
            Window:Destroy()
            SnapshotFolder:Destroy()
        end)
    end

    --Show the window.
    Window:OnRefresh()
    Window.WindowFrame.Parent = SnapshotBackgroundWindow
    Window.WindowFrame.Size = UDim2.new(0, CameraViewportSize.Y * 0.3, 0, CameraViewportSize.Y * 0.125)
    Window.WindowFrame.Position = UDim2.new(0, (CameraViewportSize.X / 2) - (Window.WindowFrame.AbsoluteSize.X / 2), 0, CameraViewportSize.Y)
    Window.WindowFrame:TweenPosition(UDim2.new(0, (CameraViewportSize.X / 2) - (Window.WindowFrame.AbsoluteSize.X / 2), 0, CameraViewportSize.Y * 0.7), "Out", "Back", 0.5, false)
end



return Command