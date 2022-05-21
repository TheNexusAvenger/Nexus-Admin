--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local CommonState = require(script.Parent.Parent:WaitForChild("CommonState"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("track","BasicCommands","Displays the name of the players through walls and a line that shows where they are.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to track.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)

    --Set up the trackers.
    for _,Player in pairs(Players) do
        --Remove the existing tracker.
        if CommonState.PlayerTrackers[Player] then
            CommonState.PlayerTrackers[Player]:Destroy()
        end

        --Add the psuedo-object.
        local FeatureFlagsApi = self.API.FeatureFlags
        local Tracker = {}
        Tracker.Active = true
        Tracker.Events = {}
        function Tracker:TrackCharacter()
            if not self.Active then return end
            if Player.Character then
                local Head = Player.Character:WaitForChild("Head")

                --Create the BillboardGui.
                local BillboardGui = Instance.new("BillboardGui")
                BillboardGui.AlwaysOnTop = true
                BillboardGui.Size = UDim2.new(20,0,20,0)
                BillboardGui.Adornee = Head
                BillboardGui.Parent = Head
                self.BillboardGui = BillboardGui

                local Text = Instance.new("TextLabel")
                Text.BackgroundTransparency = 1
                Text.Size = UDim2.new(1,0,0.5,0)
                Text.TextSize = 24
                Text.TextColor3 = Color3.new(1,1,1)
                Text.TextStrokeColor3 = Color3.new(0,0,0)
                Text.TextStrokeTransparency = 0
                Text.Text = Player.Name.."\nv"
                Text.Parent = BillboardGui
                self.Text = Text
            end
        end

        function Tracker:TrackBeam()
            --Get the source and target.
            local SourceCharacter = CommandContext.Executor.Character
            local TargetCharacter = Player.Character
            if not SourceCharacter or not TargetCharacter then return end
            local SourceUpperTorso = SourceCharacter:FindFirstChild("UpperTorso")
            local TargetUpperTorso = TargetCharacter:FindFirstChild("UpperTorso")
            local SourceHumanoidRootPart = SourceCharacter:FindFirstChild("HumanoidRootPart")
            local TargetHumanoidRootPart = TargetCharacter:FindFirstChild("HumanoidRootPart")
            if not SourceHumanoidRootPart or not TargetHumanoidRootPart or SourceHumanoidRootPart == TargetHumanoidRootPart then return end
            local SourceRootAttachment = (SourceUpperTorso and SourceUpperTorso:FindFirstChild("BodyFrontAttachment")) or SourceHumanoidRootPart:FindFirstChild("RootAttachment")
            local TargetRootAttachment = (TargetUpperTorso and TargetUpperTorso:FindFirstChild("BodyFrontAttachment")) or TargetHumanoidRootPart:FindFirstChild("RootAttachment")
            if not SourceRootAttachment or not TargetRootAttachment then return end

            --Remove the beam if the feature flag is disabled.
            if not FeatureFlagsApi:GetFeatureFlag("UseBeamsWhenTracking") then
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
            CommonState.PlayerTrackers[Player] = nil
            self.Active = false
            if self.BillboardGui then
                self.BillboardGui:Destroy()
            end
            for _, Event in pairs(self.Events) do
                Event:Disconnect()
            end
            self.Events = {}
        end
        CommonState.PlayerTrackers[Player] = Tracker

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
        table.insert(Tracker.Events, CommandContext.Executor.CharacterAdded:Connect(function()
            Tracker:TrackBeam()
            Tracker:UpdateColor()
        end))
        table.insert(Tracker.Events, FeatureFlagsApi:GetFeatureFlagChangedEvent("UseBeamsWhenTracking"):Connect(function()
            Tracker:TrackBeam()
            Tracker:UpdateColor()
        end))
        task.spawn(function()
            Tracker:TrackCharacter()
            Tracker:TrackBeam()
            Tracker:UpdateColor()
        end)
    end
end



return Command