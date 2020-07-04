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
        local Tracker = {}
        Tracker.Active = true
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
        function Tracker:UpdateColor()
            if not self.Active then return end
            if self.Text then
                if Player.Neutral == true then
                    self.Text.TextColor3 = Color3.new(1,1,1)
                else
                    self.Text.TextColor3 = Player.TeamColor.Color
                end
            end
        end
        function Tracker:Destroy()
            CommonState.PlayerTrackers[Player] = nil
            self.Active = false
            if self.BillboardGui then
                self.BillboardGui:Destroy()
            end
            if self.CharacterAddedEvent then
                self.CharacterAddedEvent:Disconnect()
                self.CharacterAddedEvent = nil
            end
            if self.TeamNeutralChangedConnection then
                self.TeamNeutralChangedConnection:Disconnect()
                self.TeamNeutralChangedConnection = nil
            end
            if self.TeamColorChangedConnection then
                self.TeamColorChangedConnection:Disconnect()
                self.TeamColorChangedConnection = nil
            end
        end
        CommonState.PlayerTrackers[Player] = Tracker

        --Connect the evnets and start tracking.
        Tracker.CharacterAddedEvent = Player.CharacterAdded:Connect(function()
            Tracker:TrackCharacter()
            Tracker:UpdateColor()
        end)
        Tracker.TeamNeutralChangedConnection = Player:GetPropertyChangedSignal("Neutral"):Connect(function()
            Tracker:UpdateColor()
        end)
        Tracker.TeamColorChangedConnection = Player:GetPropertyChangedSignal("TeamColor"):Connect(function()
            Tracker:UpdateColor()
        end)
        coroutine.wrap(function()
            Tracker:TrackCharacter()
            Tracker:UpdateColor()
        end)()
    end
end



return Command