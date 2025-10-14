--State for managing flying players.
--Run on both the client and server for server authority.
--!strict

local MAX_SPEED = 50
local MAX_SIDE_SPEED = 30
local ACCELERATION = 4 * 60
local DECELLERATION = 1 * 60
local BOOST_MULTIPLIER = 2.5
local TOGGLE_BUTTONS = {
    [Enum.KeyCode.E] = true,
    [Enum.KeyCode.ButtonX] = true,
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))

local Api = IncludedCommandUtil:GetApi()

local StartFlyEvent = (RunService:IsServer() and IncludedCommandUtil:CreateRemote("RemoteEvent", "StartFly") or IncludedCommandUtil:GetRemote("StartFly")) :: RemoteEvent
local StopFlyEvent = (RunService:IsServer() and IncludedCommandUtil:CreateRemote("RemoteEvent", "StopFly") or IncludedCommandUtil:GetRemote("StopFly")) :: RemoteEvent
local ToggleFlyEvent = (RunService:IsServer() and IncludedCommandUtil:CreateRemote("RemoteEvent", "ToggleFly") or IncludedCommandUtil:GetRemote("ToggleFly")) :: RemoteEvent
local ToggleBoostEvent = (RunService:IsServer() and IncludedCommandUtil:CreateRemote("RemoteEvent", "ToggleBoost") or IncludedCommandUtil:GetRemote("ToggleBoost")) :: RemoteEvent
local UpdateMovementEvent = (RunService:IsServer() and IncludedCommandUtil:CreateRemote("UnreliableRemoteEvent", "UpdateMovement") or IncludedCommandUtil:GetRemote("UpdateMovement")) :: UnreliableRemoteEvent

local FlyState = {}
FlyState._CurrentInstances = {} :: {[Player]: FlyState}
FlyState.__index = FlyState

export type FlyState = {
    Active: boolean,
    BoostActive: boolean,
    SpeedMultiplier: number,
    _LastUpdateTime: number,
    _LastActive: boolean,
    _CurrentAim: CFrame,
    _CurrentForwardSpeed: number,
    _CurrentSideSpeed: number,
    _InitialCollisionGroup: string?,
    _Player: Player,
    _Character: Model,
    _HumanoidRootPart: BasePart,
    _Humanoid: Humanoid,
    _Gyro: BodyGyro,
    _Velocity: BodyVelocity,
    _MoveDirection: Vector3,
    _EventConnections: {RBXScriptConnection},
} & typeof(setmetatable({}, FlyState))



--[[
Creates a fly state.
--]]
function FlyState.new(Player: Player, Character: Model, SpeedMultiplier: number?): FlyState
    --Get the character components.
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart
    local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid

    --Create the physics components.
    local Gyro = (HumanoidRootPart:FindFirstChild("NexusAdminFlyBodyGyro") or Instance.new("BodyGyro")) :: BodyGyro
    Gyro.Name = "NexusAdminFlyBodyGyro"
    Gyro.MaxTorque = Vector3.zero
    Gyro.D = 250
    Gyro.P = 10000
    Gyro:SetAttribute("IsServer", Gyro:GetAttribute("IsServer") or RunService:IsServer())
    Gyro.Parent = HumanoidRootPart

    local Velocity = (HumanoidRootPart:FindFirstChild("NexusAdminFlyBodyVelocity") or Instance.new("BodyVelocity")) :: BodyVelocity
    Velocity.Name = "NexusAdminFlyBodyVelocity"
    Velocity.MaxForce = Vector3.zero
    Velocity.Velocity = Vector3.zero
    Velocity:SetAttribute("IsServer", Velocity:GetAttribute("IsServer") or RunService:IsServer())
    Velocity.Parent = HumanoidRootPart

    --Create the object.
    local self = setmetatable({
        Active = true,
        BoostActive = false,
        SpeedMultiplier = SpeedMultiplier or 1,
        _LastUpdateTime = tick(),
        _CurrentAim = CFrame.identity,
        _CurrentForwardSpeed = 0,
        _CurrentSideSpeed = 0,
        _LastActive = false,
        _Player = Player,
        _Character = Character,
        _Humanoid = Humanoid,
        _HumanoidRootPart = HumanoidRootPart,
        _Gyro = Gyro,
        _Velocity = Velocity,
        _MoveDirection = Humanoid.MoveDirection,
        _EventConnections = {},
    }, FlyState) :: FlyState

    --Connect inputs on the client.
    if RunService:IsClient() then
        table.insert(self._EventConnections, Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            self._MoveDirection = Humanoid.MoveDirection
        end))

        ContextActionService:BindAction("ToggleFlight", function(ActionName, UserInputState, InputObject)
            if UserInputState ~= Enum.UserInputState.End then return end
            self.Active = not self.Active
            ToggleFlyEvent:FireServer(self.Active)
        end, true)
        ContextActionService:SetTitle("ToggleFlight", "Toggle Flight")
        ContextActionService:SetPosition("ToggleFlight", UDim2.new(0, 50, 0, 100))

        table.insert(self._EventConnections, UserInputService.InputBegan:Connect(function(Input, Processed)
            if Processed then return end
            if not TOGGLE_BUTTONS[Input.KeyCode] then return end
            self.Active = not self.Active
            ToggleFlyEvent:FireServer(self.Active)
        end))

        local BoostButtonsDown = {
            [Enum.KeyCode.LeftShift] = false,
            [Enum.KeyCode.RightShift] = false,
            [Enum.KeyCode.ButtonL3] = false,
        }

        table.insert(self._EventConnections, UserInputService.InputBegan:Connect(function(Input, Processed)
            if Processed then return end
            if BoostButtonsDown[Input.KeyCode] == nil then return end
            BoostButtonsDown[Input.KeyCode] = true
            self.BoostActive = true
            ToggleBoostEvent:FireServer(self.BoostActive)
        end))

        table.insert(self._EventConnections, UserInputService.InputEnded:Connect(function(Input)
            if BoostButtonsDown[Input.KeyCode] == nil then return end
            BoostButtonsDown[Input.KeyCode] = false
            for _, InputDown in BoostButtonsDown do
                if InputDown then return end
            end
            self.BoostActive = false
            ToggleBoostEvent:FireServer(self.BoostActive)
        end))
    end

    --Update the fly state.
    table.insert(self._EventConnections, RunService.Stepped:Connect(function()
        self:_Update()
    end))

    --Update the aim.
    if RunService:IsClient() then
        table.insert(self._EventConnections, RunService.RenderStepped:Connect(function()
            self._CurrentAim = Workspace.CurrentCamera:GetRenderCFrame().Rotation
            UpdateMovementEvent:FireServer(self._CurrentAim, self._MoveDirection)
        end))
    end

    --Replace the components if server versions get created.
    if RunService:IsClient() then
        table.insert(self._EventConnections, HumanoidRootPart.ChildAdded:Connect(function(Child)
            if Child:IsA("BodyGyro") and Child.Name == "NexusAdminFlyBodyGyro" and Child:GetAttribute("IsServer") then
                self._LastActive = false --Forces the values to be updated.
                Gyro:Destroy()
                self._Gyro = Child
            elseif Child:IsA("BodyVelocity") and Child.Name == "NexusAdminFlyBodyVelocity" and Child:GetAttribute("IsServer") then
                self._LastActive = false --Forces the values to be updated.
                Velocity:Destroy()
                self._Velocity = Child
            end
        end))
    end

    --Stop the fly state on death.
    table.insert(self._EventConnections, Humanoid.Died:Connect(function()
        self:Destroy()
    end))
    table.insert(self._EventConnections, Player.CharacterAdded:Connect(function()
        self:Destroy()
    end))

    --Store the instance.
    self._CurrentInstances[Player] = self
    if RunService:IsServer() then
        StartFlyEvent:FireClient(Player, SpeedMultiplier)
    end

    --Return the object.
    return self
end

--[[
Adds flying to a player.
--]]
function FlyState.AddToPlayer(Player: Player, SpeedMultiplier: number?): ()
    --Update the speed multiplier of an existing one.
    if FlyState._CurrentInstances[Player] then
        FlyState._CurrentInstances[Player].Active = true
        FlyState._CurrentInstances[Player].SpeedMultiplier = SpeedMultiplier or 1
        if RunService:IsServer() then
            StartFlyEvent:FireClient(Player, SpeedMultiplier)
        end
        return
    end

    --Create a new fly state if the character is valid.
    local Character = Player.Character
    if not Character then return end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
    if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then return end
    FlyState.new(Player, Character, SpeedMultiplier)
end

--[[
Removes flying from a player.
--]]
function FlyState.RemoveFromPlayer(Player: Player): ()
    if not FlyState._CurrentInstances[Player] then return end
    FlyState._CurrentInstances[Player]:Destroy()
end

--[[
Stops the current fly.
Should only be called by _Update.
--]]
function FlyState._Stop(self: FlyState): ()
    --Disable the flight.
    self._Gyro.MaxTorque = Vector3.zero
    self._Velocity.MaxForce = Vector3.zero
    self._Humanoid.PlatformStand = false
    self._CurrentForwardSpeed = 0
    self._CurrentSideSpeed = 0
    
    --Reset the collision groups.
    local InitialCollisionGroup = self._InitialCollisionGroup
    if InitialCollisionGroup then
        for _, Part in self._Character:GetDescendants() do
            if Part:IsA("BasePart") and Part.CollisionGroup == "NexusAdmin_FlyingPlayerCollisionGroup" then
                Part.CollisionGroup = InitialCollisionGroup
            end
        end
    end
end

--[[
Updates the fly state.
--]]
function FlyState._Update(self: FlyState): ()
    --Update the time.
    local CurrentTime = tick()
    local Delta = CurrentTime - self._LastUpdateTime
    self._LastUpdateTime = CurrentTime

    --Update the fly state starting or stopping.
    if self.Active ~= self._LastActive then
        if self.Active then
            --Enable the flight.
            self._Gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            self._Velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            self._Humanoid.PlatformStand = true

            --Set the collision groups.
            if RunService:IsServer() and Api.FeatureFlags:GetFeatureFlag("AllowFlyingThroughMap") then
                self._InitialCollisionGroup = self._HumanoidRootPart.CollisionGroup
                for _,Part in self._Character:GetDescendants() do
                    if Part:IsA("BasePart") and Part.CollisionGroup == self._InitialCollisionGroup then
                        Part.CollisionGroup = "NexusAdmin_FlyingPlayerCollisionGroup"
                    end
                end
            end
        else
            --Disable the flight.
            self:_Stop()
        end
        self._LastActive = self.Active
    end
    if not self.Active then return end

    --Convert the move direction to local space.
    local CurrentAim = self._CurrentAim
    local AimFlatLookVector = Vector3.new(CurrentAim.LookVector.X, 0, CurrentAim.LookVector.Z).Unit
    local CurrentAimRotation = CFrame.new(Vector3.zero, AimFlatLookVector).Rotation
    local MoveDirection = (CurrentAimRotation:Inverse() * CFrame.new(self._MoveDirection)).Position

    --Update the forward speed.
    local SpeedMultiplier = self.SpeedMultiplier * (self.BoostActive and BOOST_MULTIPLIER or 1)
    local NewForwardSpeed = self._CurrentForwardSpeed
    local ForwardAcceleration = ACCELERATION * MoveDirection.Z
    local MaxSpeed = SpeedMultiplier * MAX_SPEED
    if math.abs(MoveDirection.Z) < 0.1 then
        ForwardAcceleration = -DECELLERATION * math.sign(NewForwardSpeed)
    end
    NewForwardSpeed = math.clamp(NewForwardSpeed + (Delta * SpeedMultiplier * ForwardAcceleration), -MaxSpeed, MaxSpeed)
    
    --Update the side speed.
    local NewSideSpeed = self._CurrentSideSpeed
    local SideAcceleration = ACCELERATION * MoveDirection.X
    local MaxSideSpeed = SpeedMultiplier * MAX_SIDE_SPEED
    if math.abs(MoveDirection.X) < 0.1 then
        SideAcceleration = -DECELLERATION * math.sign(NewSideSpeed)
    end
    NewSideSpeed = math.clamp(NewSideSpeed + (Delta * SpeedMultiplier * SideAcceleration), -MaxSideSpeed, MaxSideSpeed)
    
    --If the signs change, set the speeds to 0 to avoid minor vibrations.
    if (NewForwardSpeed > 0 and self._CurrentForwardSpeed < 0) or (NewForwardSpeed < 0 and self._CurrentForwardSpeed > 0) then
        NewForwardSpeed = 0
    end
    if (NewSideSpeed > 0 and self._CurrentSideSpeed < 0) or (NewSideSpeed < 0 and self._CurrentSideSpeed > 0) then
        NewSideSpeed = 0
    end
    self._CurrentForwardSpeed = NewForwardSpeed
    self._CurrentSideSpeed = NewSideSpeed

    --Update the fly state.
    self._Gyro.CFrame = CurrentAim * CFrame.Angles(math.rad(math.clamp(NewForwardSpeed / 2, -90, 90)), 0, 0)
    self._Velocity.Velocity = (CurrentAim * CFrame.new(NewSideSpeed, 0, NewForwardSpeed)).Position
end

--[[
Destroys the fly state.
--]]
function FlyState.Destroy(self: FlyState): ()
    --Stop the flight.
    self:_Stop()

    --Destroy the instances.
    self._Gyro:Destroy()
    self._Velocity:Destroy()

    --Disconnect the events.
    for _, EventConnection in self._EventConnections :: {RBXScriptConnection} do
        EventConnection:Disconnect()
    end
    table.clear(self._EventConnections)

    --Remove the ContextActionService binding.
    if RunService:IsClient() then
        ContextActionService:UnbindAction("ToggleFlight")
    end

    --Remove the stored instance.
    if self._CurrentInstances[self._Player] == self then
        self._CurrentInstances[self._Player] = nil
    end

    --Notify the client.
    if RunService:IsServer() then
        StopFlyEvent:FireClient(self._Player)
    end
end



if RunService:IsClient() then
    --Set up the replication.
    StartFlyEvent.OnClientEvent:Connect(function(SpeedMultiplier: number?)
        FlyState.AddToPlayer(Players.LocalPlayer, SpeedMultiplier)
    end)

    StopFlyEvent.OnClientEvent:Connect(function()
        FlyState.RemoveFromPlayer(Players.LocalPlayer)
    end)
else
    --Set up the replication.
    ToggleFlyEvent.OnServerEvent:Connect(function(Player, Active: boolean)
        local FlyInstance = FlyState._CurrentInstances[Player]
        if not FlyInstance then return end
        FlyInstance.Active = Active
    end)
    ToggleBoostEvent.OnServerEvent:Connect(function(Player, Active: boolean)
        local FlyInstance = FlyState._CurrentInstances[Player]
        if not FlyInstance then return end
        FlyInstance.BoostActive = Active
    end)
    UpdateMovementEvent.OnServerEvent:Connect(function(Player, Aim: CFrame, MoveDirection: Vector3)
        local FlyInstance = FlyState._CurrentInstances[Player]
        if not FlyInstance then return end
        FlyInstance._CurrentAim = Aim
        FlyInstance._MoveDirection = MoveDirection
    end)

    --Set up the collision group.
    Api.FeatureFlags:AddFeatureFlag("AllowFlyingThroughMap", true)
    task.spawn(function()
        while true do
            --Determine if the flying collision group exists.
            local HasFlyCollisionGroup = false
            for _,CollisionGroup in PhysicsService:GetRegisteredCollisionGroups() do
                if CollisionGroup.name == "NexusAdmin_FlyingPlayerCollisionGroup" then
                    HasFlyCollisionGroup = true
                    break
                end
            end

            --Set up the collision group for flying.
            local AllowFlyingThroughMap = Api.FeatureFlags:GetFeatureFlag("AllowFlyingThroughMap")
            if AllowFlyingThroughMap and not HasFlyCollisionGroup then
                PhysicsService:RegisterCollisionGroup("NexusAdmin_FlyingPlayerCollisionGroup")
                HasFlyCollisionGroup = true
            end

            --Update the collision groups.
            if HasFlyCollisionGroup then
                for _, CollisionGroup in PhysicsService:GetRegisteredCollisionGroups() do
                    PhysicsService:CollisionGroupSetCollidable(CollisionGroup.name, "NexusAdmin_FlyingPlayerCollisionGroup", not AllowFlyingThroughMap)
                end
            end

            --Wait to run again.
            task.wait(5)
        end
    end)

    --Clear fly states on leave.
    Players.PlayerRemoving:Connect(function(Player)
        local FlyInstance = FlyState._CurrentInstances[Player]
        if not FlyInstance then return end
        FlyInstance:Destroy()
    end)
end



return FlyState