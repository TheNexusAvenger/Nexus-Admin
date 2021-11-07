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
    self:InitializeSuper("fly","UsefulFunCommands","Gives a set of players the ability to fly. Use E to toggle on/off.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to fly.",
        },
    }

    --Connect the remote event.
    self.API.EventContainer:WaitForChild("FlyPlayer").OnClientEvent:Connect(function()
        local Character = self.Players.LocalPlayer.Character
        if Character then
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if HumanoidRootPart and Humanoid then
                --Stop the existing flight.
                if CommonState.CurrentFlight then
                    CommonState.CurrentFlight:Destroy()
                end
                
                --Create the physics components.
                local Gyro = Instance.new("BodyGyro")
                Gyro.MaxTorque = Vector3.new(0,0,0)
                Gyro.D = 250
                Gyro.P = 10000
                Gyro.Parent = HumanoidRootPart

                local Velocity = Instance.new("BodyVelocity")
                Velocity.MaxForce = Vector3.new(0,0,0)
                Velocity.Velocity = Vector3.new(0,0,0)
                Velocity.Parent = HumanoidRootPart

                --Create the psuedo-object.
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
                Flight.MaxSpeed = 50
                Flight.SideSpeed = 0
                Flight.MaxSideSpeed = 30
                Flight.Acceleration = 4 * 60
                Flight.Decceleration = 1 * 60
                Flight.FrontMultiplier = 0
                Flight.SideMultiplier = 0
                Flight.ShiftDownMultiplier = 2.5
                Flight.Command = self

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
                function Flight:IncrementSpeed(SpeedName,Increment)
                    local OldSpeed = self[SpeedName]
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
                        self.Gyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
                        self.Velocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                        self.Humanoid.PlatformStand = true
                        self:UpdateMultipliers()

                        --Set the collision groups if the feature is enabled.
                        if self.Command.API.FeatureFlags:GetFeatureFlag("AllowFlyingThroughMap") then
                            --Determine the new collision group.
                            self.FlightCollisionGroup = nil
                            for _,CollisionGroup in pairs(self.Command.PhysicsService:GetCollisionGroups()) do
                                if CollisionGroup.name == "NexusAdmin_FlyingPlayerCollisionGroup" then
                                    self.FlightCollisionGroup = CollisionGroup.id
                                    self.InitialCollisionGroup = HumanoidRootPart.CollisionGroupId
                                    break
                                end
                            end

                            --Set the collision groups if the flying collision group exists.
                            if self.FlightCollisionGroup then
                                for _,Part in pairs(Character:GetDescendants()) do
                                    if Part:IsA("BasePart") and Part.CollisionGroupId == self.InitialCollisionGroup then
                                        Part.CollisionGroupId = self.FlightCollisionGroup
                                    end
                                end
                            end
                        end

                        --Connect the updates.
                        self.Command.RunService:BindToRenderStep("NexusAdminFlyStep",500,function(Delta)
                            --Get the rotation.
                            local _,_,_,A,B,C,D,E,F,G,H,I = self.Command.Workspace.CurrentCamera.CFrame:components()
                            local Rotation = CFrame.new(0,0,0,A,B,C,D,E,F,G,H,I)
                            
                            --Determine the speeds and accelerations.
                            local ShiftMultiplier = ((self.KeysDown[Enum.KeyCode.LeftShift] or self.KeysDown[Enum.KeyCode.RightShift]) and self.ShiftDownMultiplier or 1)
                            local MaxSpeed = self.MaxSpeed * ShiftMultiplier
                            local MaxSideSpeed = self.MaxSideSpeed * ShiftMultiplier
                            local Acceleration = self.Acceleration * ShiftMultiplier
                            local Decceleration = self.Decceleration * ShiftMultiplier

                            --Update the speeds.
                            if self.FrontMultiplier == 1 then
                                if self.FrontSpeed < 0 then
                                    self:IncrementSpeed("FrontSpeed",Acceleration * Delta)
                                elseif self.FrontSpeed < MaxSpeed then
                                    self:IncrementSpeed("FrontSpeed",Decceleration * Delta)
                                end 
                            elseif self.FrontMultiplier == -1 then
                                if self.FrontSpeed > -0 then
                                    self:IncrementSpeed("FrontSpeed",-Acceleration * Delta)
                                elseif self.FrontSpeed > -MaxSpeed then
                                    self:IncrementSpeed("FrontSpeed",-Decceleration * Delta)
                                end
                            elseif self.FrontMultiplier == 0 then
                                if self.FrontSpeed > 0 then
                                    self:IncrementSpeed("FrontSpeed",-Decceleration * Delta)
                                elseif self.FrontSpeed < 0 then
                                    self:IncrementSpeed("FrontSpeed",Decceleration * Delta)
                                end
                            end
                            
                            if self.SideMultiplier == 1 then
                                if self.SideSpeed < 0 then
                                    self:IncrementSpeed("SideSpeed",Acceleration * Delta)
                                elseif self.SideSpeed < MaxSideSpeed then
                                    self:IncrementSpeed("SideSpeed",Decceleration * Delta)
                                end 
                            elseif self.SideMultiplier == -1 then
                                if self.SideSpeed > 0 then
                                    self:IncrementSpeed("SideSpeed",-Acceleration * Delta)
                                elseif self.SideSpeed > -MaxSideSpeed then
                                    self:IncrementSpeed("SideSpeed",-Decceleration * Delta)
                                end
                            elseif self.SideMultiplier == 0 then
                                if self.SideSpeed > 0 then
                                    self:IncrementSpeed("SideSpeed",-Decceleration * Delta)
                                elseif self.SideSpeed < 0 then
                                    self:IncrementSpeed("SideSpeed",Decceleration * Delta)
                                end
                            end
                            
                            --Set the physics properties.
                            self.Gyro.CFrame = Rotation * CFrame.Angles(math.rad(self.FrontSpeed/2),0,0)
                            self.Velocity.Velocity = (Rotation * CFrame.new(self.SideSpeed,0,self.FrontSpeed)).p
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
                        self.Gyro.MaxTorque = Vector3.new(0,0,0)
                        self.Velocity.MaxForce = Vector3.new(0,0,0)
                        self.Humanoid.PlatformStand = false
                        self.FrontMultiplier = 0
                        self.SideMultiplier = 0
                        self.FrontSpeed = 0
                        self.SideSpeed = 0
                        self.Command.RunService:UnbindFromRenderStep("NexusAdminFlyStep")

                        --Reset the collision groups.
                        if self.FlightCollisionGroup then
                            for _,Part in pairs(Character:GetDescendants()) do
                                if Part:IsA("BasePart") and Part.CollisionGroupId == self.FlightCollisionGroup then
                                    Part.CollisionGroupId = self.InitialCollisionGroup
                                end
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
                    if CommonState.CurrentFlight == self then
                        CommonState.CurrentFlight = nil
                    end
                end

                --Connect the events.
                table.insert(Flight.Events,Humanoid.Died:Connect(function()
                    Flight:Destroy()
                end))
                table.insert(Flight.Events,self.UserInputService.InputBegan:Connect(function(Key)
                    if self.UserInputService:GetFocusedTextBox() then return end

                    --Handle the key.
                    if Key.KeyCode == Enum.KeyCode.E then
                        --Toggle the flight.
                        if Flight.Active then
                            Flight:Stop()
                        else
                            Flight:Start()
                        end
                    elseif Flight.KeysDown[Key.KeyCode] ~= nil then
                        --Update the key press.
                        Flight.KeysDown[Key.KeyCode] = true
                        Flight:UpdateMultipliers()
                    end
                end))
                table.insert(Flight.Events,self.UserInputService.InputEnded:Connect(function(Key)
                    if Flight.KeysDown[Key.KeyCode] ~= nil then
                        --Update the key press.
                        Flight.KeysDown[Key.KeyCode] = false
                        Flight:UpdateMultipliers()
                    end
                end))

                --Store the psuedo-object and start the flight.
                CommonState.CurrentFlight = Flight
                Flight:Start()
            end
        end
    end)
end



return Command