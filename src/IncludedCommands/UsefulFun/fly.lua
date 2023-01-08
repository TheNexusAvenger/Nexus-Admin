--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "fly",
    Category = "UsefulFunCommands",
    Description = "Gives a set of players the ability to fly. Use E to toggle on/off.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to fly.",
        },
        {
            Type = "number",
            Name = "SpeedMultiplier",
            Description = "Speed multiplier to apply to the fly speed.",
            Optional = true,
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        (IncludedCommandUtil:GetRemote("FlyPlayer") :: RemoteEvent).OnClientEvent:Connect(function(SpeedMultiplier)
            SpeedMultiplier = SpeedMultiplier or 1
    
            local Character = Players.LocalPlayer.Character
            if Character then
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if HumanoidRootPart and Humanoid then
                    --Stop the existing flight.
                    if Api.CommandData.CurrentFlight then
                        Api.CommandData.CurrentFlight:Destroy()
                    end
                    
                    --Create the physics components.
                    local Gyro = Instance.new("BodyGyro")
                    Gyro.MaxTorque = Vector3.new(0, 0, 0)
                    Gyro.D = 250
                    Gyro.P = 10000
                    Gyro.Parent = HumanoidRootPart
    
                    local Velocity = Instance.new("BodyVelocity")
                    Velocity.MaxForce = Vector3.new(0, 0, 0)
                    Velocity.Velocity = Vector3.new(0, 0, 0)
                    Velocity.Parent = HumanoidRootPart
    
                    --Create the object.
                    local Flight = {}
                    Flight.Events = {}
                    Flight.KeysDown = {
                        [Enum.KeyCode.W] = false,
                        [Enum.KeyCode.A] = false,
                        [Enum.KeyCode.S] = false,
                        [Enum.KeyCode.D] = false,
                        [Enum.KeyCode.LeftShift] = false,
                        [Enum.KeyCode.RightShift] = false,
                    }
                    Flight.Humanoid = Humanoid
                    Flight.HumanoidRootPart = HumanoidRootPart
                    Flight.Gyro = Gyro
                    Flight.Velocity = Velocity
                    Flight.Active = false
                    Flight.FrontSpeed = 0
                    Flight.MaxSpeed = 50 * SpeedMultiplier
                    Flight.SideSpeed = 0
                    Flight.MaxSideSpeed = 30 * SpeedMultiplier
                    Flight.Acceleration = 4 * 60 * SpeedMultiplier
                    Flight.Decceleration = 1 * 60 * SpeedMultiplier
                    Flight.FrontMultiplier = 0
                    Flight.SideMultiplier = 0
                    Flight.ShiftDownMultiplier = 2.5 * SpeedMultiplier
    
                    --[[
                    Updates the multipliers.
                    --]]
                    function Flight:UpdateMultipliers()
                        --Update the forward multiplier.
                        self.FrontMultiplier = (self.KeysDown[Enum.KeyCode.S] and 1 or 0) - (self.KeysDown[Enum.KeyCode.W] and 1 or 0)
    
                        --Update the side multiplier.
                        self.SideMultiplier = (self.KeysDown[Enum.KeyCode.D] and 1 or 0) - (self.KeysDown[Enum.KeyCode.A] and 1 or 0)
                    end
    
                    --[[
                    Increments the side speed.
                    --]]
                    function Flight:IncrementSpeed(SpeedName: string, Increment: number)
                        local OldSpeed = self[SpeedName] :: number
                        local NewSpeed = OldSpeed + Increment
                        
                        --Set the speed. If the speed changes signs, set it to 0 to prevent overcompensating when slowing down.
                        if OldSpeed ~= 0 and ((OldSpeed > 0 and NewSpeed < 0) or (OldSpeed < 0 and NewSpeed > 0)) then
                            self[SpeedName] = 0
                        else
                            self[SpeedName] = NewSpeed
                        end
                    end
    
                    --[[
                    Starts the flight.
                    --]]
                    function Flight:Start()
                        if not self.Active then
                            self.Active = true
    
                            --Enable the flight.
                            self.Gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                            self.Gyro.Parent = HumanoidRootPart
                            self.Velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            self.Velocity.Parent = HumanoidRootPart
                            self.Humanoid.PlatformStand = true
                            self:UpdateMultipliers()
    
                            --Set the collision groups if the feature is enabled.
                            if Api.FeatureFlags:GetFeatureFlag("AllowFlyingThroughMap") then
                                --Determine the new collision group.
                                for _, CollisionGroup in PhysicsService:GetRegisteredCollisionGroups() do
                                    if CollisionGroup.name == "NexusAdmin_FlyingPlayerCollisionGroup" then
                                        self.InitialCollisionGroup = HumanoidRootPart.CollisionGroup
                                        break
                                    end
                                end
    
                                --Set the collision groups if the flying collision group exists.
                                for _,Part in Character:GetDescendants() do
                                    if Part:IsA("BasePart") and Part.CollisionGroup == self.InitialCollisionGroup then
                                        Part.CollisionGroup = "NexusAdmin_FlyingPlayerCollisionGroup"
                                    end
                                end
                            end
    
                            --Connect the updates.
                            RunService:BindToRenderStep("NexusAdminFlyStep", 500, function(Delta)
                                --Get the rotation.
                                local Rotation = CFrame.new(-Workspace.CurrentCamera.CFrame.Position) * Workspace.CurrentCamera.CFrame
                                
                                --Determine the speeds and accelerations.
                                local ShiftMultiplier = ((self.KeysDown[Enum.KeyCode.LeftShift] or self.KeysDown[Enum.KeyCode.RightShift]) and self.ShiftDownMultiplier or 1)
                                local MaxSpeed = (self.MaxSpeed :: number) * ShiftMultiplier
                                local MaxSideSpeed = (self.MaxSideSpeed :: number) * ShiftMultiplier
                                local Acceleration = (self.Acceleration :: number) * ShiftMultiplier
                                local Decceleration = (self.Decceleration :: number) * ShiftMultiplier
    
                                --Update the speeds.
                                if self.FrontMultiplier == 1 then
                                    if self.FrontSpeed < 0 then
                                        self:IncrementSpeed("FrontSpeed", Acceleration * Delta)
                                    elseif self.FrontSpeed < MaxSpeed then
                                        self:IncrementSpeed("FrontSpeed", Decceleration * Delta)
                                    end 
                                elseif self.FrontMultiplier == -1 then
                                    if self.FrontSpeed > -0 then
                                        self:IncrementSpeed("FrontSpeed", -Acceleration * Delta)
                                    elseif self.FrontSpeed > -MaxSpeed then
                                        self:IncrementSpeed("FrontSpeed", -Decceleration * Delta)
                                    end
                                elseif self.FrontMultiplier == 0 then
                                    if self.FrontSpeed > 0 then
                                        self:IncrementSpeed("FrontSpeed", -Decceleration * Delta)
                                    elseif self.FrontSpeed < 0 then
                                        self:IncrementSpeed("FrontSpeed", Decceleration * Delta)
                                    end
                                end
                                
                                if self.SideMultiplier == 1 then
                                    if self.SideSpeed < 0 then
                                        self:IncrementSpeed("SideSpeed", Acceleration * Delta)
                                    elseif self.SideSpeed < MaxSideSpeed then
                                        self:IncrementSpeed("SideSpeed", Decceleration * Delta)
                                    end 
                                elseif self.SideMultiplier == -1 then
                                    if self.SideSpeed > 0 then
                                        self:IncrementSpeed("SideSpeed", -Acceleration * Delta)
                                    elseif self.SideSpeed > -MaxSideSpeed then
                                        self:IncrementSpeed("SideSpeed", -Decceleration * Delta)
                                    end
                                elseif self.SideMultiplier == 0 then
                                    if self.SideSpeed > 0 then
                                        self:IncrementSpeed("SideSpeed", -Decceleration * Delta)
                                    elseif self.SideSpeed < 0 then
                                        self:IncrementSpeed("SideSpeed", Decceleration * Delta)
                                    end
                                end
                                
                                --Set the physics properties.
                                self.Gyro.CFrame = Rotation * CFrame.Angles(math.rad(math.clamp(self.FrontSpeed / 2, -90, 90)), 0, 0)
                                self.Velocity.Velocity = (Rotation * CFrame.new(self.SideSpeed, 0, self.FrontSpeed)).p
                            end)
                        end
                    end
    
                    --[[
                    Stops the flight.
                    --]]
                    function Flight:Stop()
                        if self.Active then
                            self.Active = false
    
                            --Disable the flight.
                            self.Gyro.MaxTorque = Vector3.new(0, 0, 0)
                            self.Gyro.Parent = nil
                            self.Velocity.MaxForce = Vector3.new(0, 0, 0)
                            self.Velocity.Parent = nil
                            self.Humanoid.PlatformStand = false
                            self.FrontMultiplier = 0
                            self.SideMultiplier = 0
                            self.FrontSpeed = 0
                            self.SideSpeed = 0
                            RunService:UnbindFromRenderStep("NexusAdminFlyStep")
    
                            --Reset the collision groups.
                            for _, Part in Character:GetDescendants() do
                                if Part:IsA("BasePart") and Part.CollisionGroup == "NexusAdmin_FlyingPlayerCollisionGroup" then
                                    Part.CollisionGroup = self.InitialCollisionGroup
                                end
                            end
                        end
                    end
    
                    --[[
                    Destroys the flight.
                    --]]
                    function Flight:Destroy()
                        --Stop the flight.
                        self:Stop()
    
                        --Destory the physics objects.
                        self.Gyro:Destroy()
                        self.Velocity:Destroy()
    
                        --Disconnect the events.
                        for _,Event in pairs(self.Events) do
                            Event:Disconnect()
                        end
    
                        --Unstore the flight.
                        if Api.CommandData.CurrentFlight == self then
                            Api.CommandData.CurrentFlight = nil
                        end
                    end
    
                    --Connect the events.
                    table.insert(Flight.Events, Humanoid.Died:Connect(function()
                        (Flight :: any):Destroy()
                    end))
                    table.insert(Flight.Events, UserInputService.InputBegan:Connect(function(Key, Processeed)
                        if Processeed and Key.KeyCode ~= Enum.KeyCode.LeftShift and Key.KeyCode ~= Enum.KeyCode.RightShift then return end
    
                        --Handle the key.
                        if Key.KeyCode == Enum.KeyCode.E then
                            --Toggle the flight.
                            if Flight.Active then
                                (Flight :: any):Stop()
                            else
                                (Flight :: any):Start()
                            end
                        elseif Flight.KeysDown[Key.KeyCode] ~= nil then
                            --Update the key press.
                            Flight.KeysDown[Key.KeyCode] = true
                            Flight:UpdateMultipliers()
                        end
                    end))
                    table.insert(Flight.Events, UserInputService.InputEnded:Connect(function(Key)
                        if Flight.KeysDown[Key.KeyCode] ~= nil then
                            --Update the key press.
                            Flight.KeysDown[Key.KeyCode] = false
                            Flight:UpdateMultipliers()
                        end
                    end))
    
                    --Store the object and start the flight.
                    Api.CommandData.CurrentFlight = Flight;
                    (Flight :: any):Start()
                end
            end
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        IncludedCommandUtil:CreateRemote("RemoteEvent", "FlyPlayer")

        --Update the collision groups.
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
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, SpeedMultiplier: number?)
        local Util = IncludedCommandUtil.ForContext(CommandContext)

        --Fly the players.
        for _, Player in Players do
            (Util:GetRemote("FlyPlayer") :: RemoteEvent):FireClient(Player, SpeedMultiplier)
        end
    end,
}