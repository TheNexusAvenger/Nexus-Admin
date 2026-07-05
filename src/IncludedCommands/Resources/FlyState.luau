--State for managing flying players.
--Run on both the client and server for server authority.
--!strict

local COLLISION_GROUP_NAME = "NexusAdmin_FlyingPlayerCollisionGroup"
local MAX_SPEED = 50
local MAX_SIDE_SPEED = 30
local ACCELERATION = 4 * 60
local DECELLERATION = 1 * 60
local BOOST_MULTIPLIER = 2.5

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))

local Api = IncludedCommandUtil:GetApi()

local StartFlyEvent = (RunService:IsServer() and IncludedCommandUtil:CreateRemote("RemoteEvent", "StartFly") or IncludedCommandUtil:GetRemote("StartFly")) :: RemoteEvent
local StopFlyEvent = (RunService:IsServer() and IncludedCommandUtil:CreateRemote("RemoteEvent", "StopFly") or IncludedCommandUtil:GetRemote("StopFly")) :: RemoteEvent

local FlyState = {}
FlyState._ContextPrefix = (RunService:IsServer() and "Server" or "Client")
FlyState._CurrentInstances = {} :: {[Player]: FlyState}
FlyState.__index = FlyState

export type FlyState = {
    SpeedMultiplier: number,
    _Active: boolean,
    _BoostActive: boolean,
    _LastActive: boolean,
    _InitialCollisionGroup: string?,
    _Player: Player,
    _Character: Model,
    _Humanoid: Humanoid,
    _HumanoidRootPart: BasePart,
    _UsingServerInputs: boolean,
    _InputContext: InputContext?,
    _Orientation: AlignOrientation?,
    _Velocity: LinearVelocity?,
    _Attachment: Attachment?,
    _EventConnections: {RBXScriptConnection},
} & typeof(setmetatable({}, FlyState))



--[[
Creates a fly state.
--]]
function FlyState.new(Player: Player, Character: Model, SpeedMultiplier: number?, InitialCollisionGroup: string?): FlyState
    --Get the character components.
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart
    local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid

    --Create the object.
    local self = setmetatable({
        SpeedMultiplier = SpeedMultiplier or 1,
        _Active = true,
        _BoostActive = false,
        _LastActive = false,
        _InitialCollisionGroup = InitialCollisionGroup,
        _Player = Player,
        _Character = Character,
        _Humanoid = Humanoid,
        _HumanoidRootPart = HumanoidRootPart,
        _UsingServerInputs = (Player:FindFirstChild("InputContexts") ~= nil),
        _EventConnections = {},
    }, FlyState) :: FlyState

    --Set the initial collision group.
    if RunService:IsServer() and not self._InitialCollisionGroup then
        local NewCollisionGroup = HumanoidRootPart.CollisionGroup
        if NewCollisionGroup ~= COLLISION_GROUP_NAME then
            self._InitialCollisionGroup = NewCollisionGroup
        end
    end

    --Connect inputs.
    --For server authority, this is set up on both the client and server.
    local Inputs = self:_GetInputs()
    if Inputs then
        self._InputContext = Inputs.Context

        table.insert(self._EventConnections, Inputs.ToggleAction.Pressed:Connect(function()
            self._Active = not self._Active
        end))

        table.insert(self._EventConnections, Inputs.BoostAction.Pressed:Connect(function()
            self._BoostActive = true
        end))

        table.insert(self._EventConnections, Inputs.BoostAction.Released:Connect(function()
            self._BoostActive = false
        end))

        if RunService:IsClient() then
            ContextActionService:BindAction("ToggleFlight", function() end, true)
            ContextActionService:SetTitle("ToggleFlight", "Toggle Flight")
            ContextActionService:SetPosition("ToggleFlight", UDim2.new(0, 50, 0, 100))
            Inputs.ToggleGuiButtonBinding.UIButton = ContextActionService:GetButton("ToggleFlight")

            table.insert(self._EventConnections, Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
                Inputs.MoveDirectionAction:Fire(Humanoid.MoveDirection)
            end))
        end
    end

    --Update the fly state.
    if Inputs then
        local function UpdateFromInputs(DeltaTime: number): ()
            local ForwardVector = Inputs.ForwardVectorAction:GetState() :: Vector3
            local UpVector = Inputs.UpVectorAction:GetState() :: Vector3
            if ForwardVector == Vector3.zero or UpVector == Vector3.zero then return end
            self:_Update(DeltaTime, CFrame.fromMatrix(Vector3.zero, ForwardVector:Cross(UpVector), UpVector, -ForwardVector), Inputs.MoveDirectionAction:GetState() :: Vector3)
        end

        xpcall(function()
            table.insert(self._EventConnections, RunService:BindToSimulation(UpdateFromInputs, Enum.StepFrequency.Hz60))
        end, function()
            table.insert(self._EventConnections, RunService.Stepped:Connect(function(_, DeltaTime)
                UpdateFromInputs(DeltaTime)
            end))
        end)
    end

    --Update the aim.
    if Inputs and RunService:IsClient() then
        table.insert(self._EventConnections, RunService.RenderStepped:Connect(function()
            local CurrentAim = Workspace.CurrentCamera:GetRenderCFrame().Rotation
            Inputs.ForwardVectorAction:Fire(CurrentAim.LookVector)
            Inputs.UpVectorAction:Fire(CurrentAim.UpVector)
        end))
    end

    --Update the collision group.
    table.insert(self._EventConnections, HumanoidRootPart:GetPropertyChangedSignal("CollisionGroup"):Connect(function()
        local NewCollisionGroup = HumanoidRootPart.CollisionGroup
        if NewCollisionGroup == COLLISION_GROUP_NAME then return end
        self._InitialCollisionGroup = NewCollisionGroup
    end))

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
        StartFlyEvent:FireClient(Player, SpeedMultiplier, self._InitialCollisionGroup)
    end

    --Return the object.
    return self
end

--[[
Adds flying to a player.
--]]
function FlyState.AddToPlayer(Player: Player, SpeedMultiplier: number?, InitialCollisionGroup: string?): ()
    --Update the speed multiplier of an existing one.
    local CurrentInstance = FlyState._CurrentInstances[Player]
    if CurrentInstance then
        CurrentInstance._Active = true
        CurrentInstance.SpeedMultiplier = SpeedMultiplier or 1
        if RunService:IsServer() then
            StartFlyEvent:FireClient(Player, SpeedMultiplier, CurrentInstance._InitialCollisionGroup)
        end
        return
    end

    --Create a new fly state if the character is valid.
    local Character = Player.Character
    if not Character then return end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
    if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then return end
    FlyState.new(Player, Character, SpeedMultiplier, InitialCollisionGroup)
end

--[[
Removes flying from a player.
--]]
function FlyState.RemoveFromPlayer(Player: Player): ()
    if not FlyState._CurrentInstances[Player] then return end
    FlyState._CurrentInstances[Player]:Destroy()
end

--[[
Creates or waits for input objects.
Can return nil if the current context isn't valid (server without server authority).
--]]
function FlyState._GetInputs(self: FlyState): {Context: InputContext, ToggleAction: InputAction, ToggleGuiButtonBinding: InputBinding, BoostAction: InputAction, MoveDirectionAction: InputAction, ForwardVectorAction: InputAction, UpVectorAction: InputAction}?
    --Return nil if running on the server without replicated inputs.
    if RunService:IsServer() and not self._UsingServerInputs then
        return nil
    end

    --Determine the parent and whether to create or wait.
    local Parent = self._Player:FindFirstChild("InputContexts") or Api.EventContainer
    local Create = (Parent:FindFirstChild("NexusAdminFlyContext") == nil)
    if RunService:IsClient() and self._UsingServerInputs then
        Create = false
    end

    --Create the inputs if they should be created.
    if Create then
        local Context = Instance.new("InputContext")
        Context.Name = "NexusAdminFlyContext"
        Context.Sink = true
        Context.Parent = Parent
	
        --Create the toggle input.
        local ToggleAction = Instance.new("InputAction")
        ToggleAction.Type = Enum.InputActionType.Bool
        ToggleAction.Name = "Toggle"
        ToggleAction.Parent = Context

        local ToggleEBinding = Instance.new("InputBinding")
        ToggleEBinding.Name = "EBinding"
        ToggleEBinding.KeyCode = Enum.KeyCode.E
        ToggleEBinding.Parent = ToggleAction

        local ToggleButtonXBinding = Instance.new("InputBinding")
        ToggleButtonXBinding.Name = "ButtonXBinding"
        ToggleButtonXBinding.KeyCode = Enum.KeyCode.ButtonX
        ToggleButtonXBinding.Parent = ToggleAction

        local ToggleGuiButtonBinding = Instance.new("InputBinding")
        ToggleGuiButtonBinding.Name = "GuiButtonBinding"
        ToggleGuiButtonBinding.Parent = ToggleAction

        --Create the boost action.
        local BoostAction = Instance.new("InputAction")
        BoostAction.Type = Enum.InputActionType.Bool
        BoostAction.Name = "Boost"
        BoostAction.Parent = Context

        local BoostLeftShiftBinding = Instance.new("InputBinding")
        BoostLeftShiftBinding.Name = "LeftShiftBinding"
        BoostLeftShiftBinding.KeyCode = Enum.KeyCode.LeftShift
        BoostLeftShiftBinding.Parent = BoostAction

        local BoostRightShiftBinding = Instance.new("InputBinding")
        BoostRightShiftBinding.Name = "RightShiftBinding"
        BoostRightShiftBinding.KeyCode = Enum.KeyCode.RightShift
        BoostRightShiftBinding.Parent = BoostAction

        local BoostButtonL3Binding = Instance.new("InputBinding")
        BoostButtonL3Binding.Name = "ButtonL3Binding"
        BoostButtonL3Binding.KeyCode = Enum.KeyCode.ButtonL3
        BoostButtonL3Binding.Parent = BoostAction

        --Create movement actions.
        local MoveDirectionAction = Instance.new("InputAction")
        MoveDirectionAction.Name = "MoveDirection"
        MoveDirectionAction.Type = Enum.InputActionType.Direction3D
        MoveDirectionAction.Parent = Context

        local ForwardVectorAction = Instance.new("InputAction")
        ForwardVectorAction.Name = "ForwardVector"
        ForwardVectorAction.Type = Enum.InputActionType.Direction3D
        ForwardVectorAction.Parent = Context

        local UpVectorAction = Instance.new("InputAction")
        UpVectorAction.Name = "UpVector"
        UpVectorAction.Type = Enum.InputActionType.Direction3D
        UpVectorAction.Parent = Context

        --Return the inputs.
        return {
            Context = Context,
            ToggleAction = ToggleAction,
            ToggleGuiButtonBinding = ToggleGuiButtonBinding,
            BoostAction = BoostAction,
            MoveDirectionAction = MoveDirectionAction,
            ForwardVectorAction = ForwardVectorAction,
            UpVectorAction = UpVectorAction,
        }
    end

    --Wait for the inputs.
    local Context = Parent:WaitForChild("NexusAdminFlyContext") :: InputContext
    local ToggleAction = Context:WaitForChild("Toggle") :: InputAction
    return {
        Context = Context,
        ToggleAction = ToggleAction,
        ToggleGuiButtonBinding = ToggleAction:WaitForChild("GuiButtonBinding") :: InputBinding,
        BoostAction = Context:WaitForChild("Boost") :: InputAction,
        MoveDirectionAction = Context:WaitForChild("MoveDirection") :: InputAction,
        ForwardVectorAction = Context:WaitForChild("ForwardVector") :: InputAction,
        UpVectorAction = Context:WaitForChild("UpVector") :: InputAction,
    }
end

--[[
Starts the current fly.
Should only be called by _Update.
--]]
function FlyState._Start(self: FlyState): ()
    --Enable the flight.
    if self._InputContext then
        self._InputContext.Sink = true
    end
    if self._Orientation then
        self._Orientation.Enabled = true
    end
    if self._Velocity then
        self._Velocity.Enabled = true
    end
    self._Humanoid.PlatformStand = true

    --Set the collision groups.
    if Api.FeatureFlags:GetFeatureFlag("AllowFlyingThroughMap") then
        for _,Part in self._Character:GetDescendants() do
            if Part:IsA("BasePart") and Part.CollisionGroup == self._InitialCollisionGroup then
                Part.CollisionGroup = COLLISION_GROUP_NAME
            end
        end
    end
end

--[[
Stops the current fly.
Should only be called by _Update.
--]]
function FlyState._Stop(self: FlyState): ()
    --Disable the flight.
    if self._InputContext then
        self._InputContext.Sink = false
    end
    if self._Orientation then
        self._Orientation.Enabled = false
    end
    if self._Velocity then
        self._Velocity.Enabled = false
        self._Velocity:SetAttribute(`{FlyState._ContextPrefix}ForwardSpeed`, 0)
        self._Velocity:SetAttribute(`{FlyState._ContextPrefix}SideSpeed`, 0)
    end
    self._Humanoid.PlatformStand = false
    
    --Reset the collision groups.
    local InitialCollisionGroup = self._InitialCollisionGroup
    if InitialCollisionGroup then
        for _, Part in self._Character:GetDescendants() do
            if Part:IsA("BasePart") and Part.CollisionGroup == COLLISION_GROUP_NAME then
                Part.CollisionGroup = InitialCollisionGroup
            end
        end
    end
end

--[[
Updates the fly state.
--]]
function FlyState._Update(self: FlyState, DeltaTime: number, InputAim: CFrame, InputMoveDirection: Vector3): ()
    --Update the fly state starting or stopping.
    if self._Active ~= self._LastActive then
        task.defer(function()
            if self._Active then
                self:_Start()
            else
                self:_Stop()
            end
        end)
        self._LastActive = self._Active
    end
    if not self._Active then return end

    --Create the instances if they don't exist.
    --This is required for BindToSimulation so they are bound.
    if not self._Orientation then
        local Attachment = Instance.new("Attachment")
        self._Attachment = Attachment
        local Orientation = Instance.new("AlignOrientation")
        self._Orientation = Orientation
        local Velocity = Instance.new("LinearVelocity")
        self._Velocity = Velocity

        task.defer(function()
            Attachment.Name = "NexusAdminFlyAttachment"
            Attachment.Parent = self._HumanoidRootPart

            Orientation.Name = "NexusAdminFlyOrientation"
            Orientation.Attachment0 = self._Attachment
            Orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
            Orientation.RigidityEnabled = true
            Orientation.Parent = self._HumanoidRootPart

            Velocity.Name = "NexusAdminFlyVelocity"
            Velocity.MaxForce = math.huge
            Velocity.Attachment0 = self._Attachment
            Velocity.Parent = self._HumanoidRootPart
        end)
    end
    local CurrentOrientation, CurrentVelocity = self._Orientation :: AlignOrientation, self._Velocity :: LinearVelocity

    --Convert the move direction to local space.
    local AimFlatLookVector = Vector3.new(InputAim.LookVector.X, 0, InputAim.LookVector.Z).Unit
    local CurrentAimRotation = CFrame.new(Vector3.zero, AimFlatLookVector).Rotation
    local MoveDirection = (CurrentAimRotation:Inverse() * CFrame.new(InputMoveDirection)).Position

    --Update the forward speed.
    local ForwardSpeedAttribute = `{FlyState._ContextPrefix}ForwardSpeed`
    local SpeedMultiplier = self.SpeedMultiplier * (self._BoostActive and BOOST_MULTIPLIER or 1)
    local CurrentForwardSpeed = CurrentVelocity:GetAttribute(ForwardSpeedAttribute) :: number or 0
    local NewForwardSpeed = CurrentForwardSpeed
    local ForwardAcceleration = ACCELERATION * MoveDirection.Z  * SpeedMultiplier
    local MaxSpeed = SpeedMultiplier * MAX_SPEED
    if math.abs(MoveDirection.Z) < 0.1 then
        ForwardAcceleration = -DECELLERATION * math.sign(NewForwardSpeed)
    end
    NewForwardSpeed = math.clamp(NewForwardSpeed + (DeltaTime * SpeedMultiplier * ForwardAcceleration), -MaxSpeed, MaxSpeed)
    
    --Update the side speed.
    local SideSpeedAttribute = `{FlyState._ContextPrefix}SideSpeed`
    local CurrentSideSpeed = CurrentVelocity:GetAttribute(SideSpeedAttribute) :: number or 0
    local NewSideSpeed = CurrentSideSpeed
    local SideAcceleration = ACCELERATION * MoveDirection.X  * SpeedMultiplier
    local MaxSideSpeed = SpeedMultiplier * MAX_SIDE_SPEED
    if math.abs(MoveDirection.X) < 0.1 then
        SideAcceleration = -DECELLERATION * math.sign(NewSideSpeed)
    end
    NewSideSpeed = math.clamp(NewSideSpeed + (DeltaTime * SpeedMultiplier * SideAcceleration), -MaxSideSpeed, MaxSideSpeed)
    
    --If the signs change, set the speeds to 0 to avoid minor vibrations.
    if (NewForwardSpeed > 0 and CurrentForwardSpeed < 0) or (NewForwardSpeed < 0 and CurrentForwardSpeed > 0) then
        NewForwardSpeed = 0
    end
    if (NewSideSpeed > 0 and CurrentSideSpeed < 0) or (NewSideSpeed < 0 and CurrentSideSpeed > 0) then
        NewSideSpeed = 0
    end
    CurrentVelocity:SetAttribute(ForwardSpeedAttribute, NewForwardSpeed)
    CurrentVelocity:SetAttribute(SideSpeedAttribute, NewSideSpeed)

    --Update the fly state.
    CurrentOrientation.CFrame = InputAim * CFrame.Angles(math.rad(math.clamp(NewForwardSpeed / 2, -90, 90)), 0, 0)
    CurrentVelocity.VectorVelocity = (InputAim * CFrame.new(NewSideSpeed, 0, NewForwardSpeed)).Position
end

--[[
Destroys the fly state.
--]]
function FlyState.Destroy(self: FlyState): ()
    --Stop the flight.
    self:_Stop()

    --Destroy the instances.
    if self._Orientation then
        self._Orientation:Destroy()
    end
    if self._Velocity then
        self._Velocity:Destroy()
    end
    if self._Attachment then
        self._Attachment:Destroy()
    end

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
    StartFlyEvent.OnClientEvent:Connect(function(SpeedMultiplier: number?, InitialCollisionGroup: string?)
        FlyState.AddToPlayer(Players.LocalPlayer, SpeedMultiplier, InitialCollisionGroup)
    end)

    StopFlyEvent.OnClientEvent:Connect(function()
        FlyState.RemoveFromPlayer(Players.LocalPlayer)
    end)
else
    --Set up the collision group.
    Api.FeatureFlags:AddFeatureFlag("AllowFlyingThroughMap", true)
    task.spawn(function()
        while true do
            --Determine if the flying collision group exists.
            local HasFlyCollisionGroup = false
            for _,CollisionGroup in PhysicsService:GetRegisteredCollisionGroups() do
                if CollisionGroup.name == COLLISION_GROUP_NAME then
                    HasFlyCollisionGroup = true
                    break
                end
            end

            --Set up the collision group for flying.
            local AllowFlyingThroughMap = Api.FeatureFlags:GetFeatureFlag("AllowFlyingThroughMap")
            if AllowFlyingThroughMap and not HasFlyCollisionGroup then
                PhysicsService:RegisterCollisionGroup(COLLISION_GROUP_NAME)
                HasFlyCollisionGroup = true
            end

            --Update the collision groups.
            if HasFlyCollisionGroup then
                for _, CollisionGroup in PhysicsService:GetRegisteredCollisionGroups() do
                    if PhysicsService:CollisionGroupsAreCollidable(CollisionGroup.name, COLLISION_GROUP_NAME) == not AllowFlyingThroughMap then continue end
                    PhysicsService:CollisionGroupSetCollidable(CollisionGroup.name, COLLISION_GROUP_NAME, not AllowFlyingThroughMap)
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