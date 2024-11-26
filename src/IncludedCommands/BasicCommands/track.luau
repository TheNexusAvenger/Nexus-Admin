--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "track",
    Category = "BasicCommands",
    Description = "Displays the name of the players through walls and a line that shows where they are.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to track.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        Api.CommandData.PlayerTrackers = {}
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        Api.FeatureFlags:AddFeatureFlag("UseBeamsWhenTracking", true)
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Set up the trackers.
        for _, Player in Players do
            --Remove the existing tracker.
            if Api.CommandData.PlayerTrackers[Player] then
                Api.CommandData.PlayerTrackers[Player]:Destroy()
            end

            --Add the object.
            local Tracker = {}
            Tracker.Active = true
            Tracker.Events = {}
            function Tracker:TrackCharacter()
                if not self.Active then return end
                if Player.Character then
                    local Head = Player.Character:WaitForChild("Head", 10 ^ 99) :: BasePart
                    if not self.Active then return end

                    --Create the BillboardGui.
                    local BillboardGui = Instance.new("BillboardGui")
                    BillboardGui.AlwaysOnTop = true
                    BillboardGui.Size = UDim2.new(20, 0, 20, 0)
                    BillboardGui.Adornee = Head
                    BillboardGui.Parent = Head
                    self.BillboardGui = BillboardGui

                    local Text = Instance.new("TextLabel")
                    Text.BackgroundTransparency = 1
                    Text.Size = UDim2.new(1, 0, 0.5, 0)
                    Text.TextSize = 24
                    Text.TextColor3 = Color3.new(1, 1, 1)
                    Text.TextStrokeColor3 = Color3.new(0, 0, 0)
                    Text.TextStrokeTransparency = 0
                    Text.Text = Player.Name.."\nv"
                    Text.Parent = BillboardGui
                    self.Text = Text
                end
            end

            function Tracker:TrackBeam()
                --Get the source and target.
                local SourceCharacter = CommandContext.Executor.Character :: Model
                local TargetCharacter = Player.Character :: Model
                if not SourceCharacter or not TargetCharacter then return end
                local SourceUpperTorso = SourceCharacter:FindFirstChild("UpperTorso") :: BasePart
                local TargetUpperTorso = TargetCharacter:FindFirstChild("UpperTorso") :: BasePart
                local SourceHumanoidRootPart = SourceCharacter:FindFirstChild("HumanoidRootPart") :: BasePart
                local TargetHumanoidRootPart = TargetCharacter:FindFirstChild("HumanoidRootPart") :: BasePart
                if not SourceHumanoidRootPart or not TargetHumanoidRootPart or SourceHumanoidRootPart == TargetHumanoidRootPart then return end
                local SourceRootAttachment = (SourceUpperTorso and SourceUpperTorso:FindFirstChild("BodyFrontAttachment")) or SourceHumanoidRootPart:FindFirstChild("RootAttachment")
                local TargetRootAttachment = (TargetUpperTorso and TargetUpperTorso:FindFirstChild("BodyFrontAttachment")) or TargetHumanoidRootPart:FindFirstChild("RootAttachment")
                if not SourceRootAttachment or not TargetRootAttachment then return end

                --Remove the beam if the feature flag is disabled.
                if not Api.FeatureFlags:GetFeatureFlag("UseBeamsWhenTracking") then
                    if self.Beam then
                        self.Beam:Destroy()
                    end
                    return
                end

                --Create and update the beam.
                if not self.Beam or not self.Beam:IsAncestorOf(game) then
                    if self.Beam then
                        self.Beam:Destroy()
                    end

                    local Beam = Instance.new("Beam")
                    Beam.LightEmission = 1
                    Beam.LightInfluence = 0
                    Beam.Transparency = NumberSequence.new(0.5)
                    Beam.Segments = 1
                    Beam.Width0 = 0.05
                    Beam.Width1 = 0.05
                    Beam.FaceCamera = true
                    Beam.Parent = self.BillboardGui
                    self.Beam = Beam
                end
                self.Beam.Attachment0 = SourceRootAttachment
                self.Beam.Attachment1 = TargetRootAttachment
            end

            function Tracker:UpdateColor()
                if not self.Active then return end
                local Color = (Player.Neutral and Color3.new(1, 1, 1) or Player.TeamColor.Color)
                if self.Text then
                    self.Text.TextColor3 = Color
                end
                if self.Beam then
                    self.Beam.Color = ColorSequence.new(Color)
                end
            end

            function Tracker:Destroy()
                Api.CommandData.PlayerTrackers[Player] = nil
                self.Active = false
                if self.BillboardGui then
                    self.BillboardGui:Destroy()
                end
                for _, Event in self.Events do
                    Event:Disconnect()
                end
                self.Events = {}
            end
            Api.CommandData.PlayerTrackers[Player] = Tracker

            --Connect the events and start tracking.
            table.insert(Tracker.Events, Player.CharacterAdded:Connect(function()
                Tracker:TrackCharacter()
                Tracker:TrackBeam()
                Tracker:UpdateColor()
            end))
            table.insert(Tracker.Events, Player:GetPropertyChangedSignal("Neutral"):Connect(function()
                Tracker:UpdateColor()
            end))
            table.insert(Tracker.Events, Player:GetPropertyChangedSignal("TeamColor"):Connect(function()
                Tracker:UpdateColor()
            end))
            table.insert(Tracker.Events, CommandContext.Executor.CharacterAdded:Connect(function(Character)
                --Wait for the beam source to be ready.
                local SourceHumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                if not Tracker.Active then return end
                while true do
                    local SourceUpperTorso = Character:FindFirstChild("UpperTorso")
                    local SourceRootAttachment = (SourceUpperTorso and SourceUpperTorso:FindFirstChild("BodyFrontAttachment")) or SourceHumanoidRootPart:FindFirstChild("RootAttachment")
                    if SourceRootAttachment then
                        break
                    end
                    task.wait()
                end

                --Set up the beam.
                Tracker:TrackBeam()
                Tracker:UpdateColor()
            end))
            table.insert(Tracker.Events, Api.FeatureFlags:GetFeatureFlagChangedEvent("UseBeamsWhenTracking"):Connect(function()
                Tracker:TrackBeam()
                Tracker:UpdateColor()
            end))
            task.spawn(function()
                Tracker:TrackCharacter()
                Tracker:TrackBeam()
                Tracker:UpdateColor()
            end)
        end
    end,
}