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
    self:InitializeSuper("jail","UsefulFunCommands","Creates a jail around a set of players. Each player can only have one jail.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to jail.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Create the jails.
    for _,Player in pairs(Players) do
        local Character = Player.Character
        if not CommonState.PlayerJails[Player] and Character then
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                --Create the jail.
                local Center = HumanoidRootPart.CFrame
                local Jail = Instance.new("Model")
                Jail.Name = "Jail_"..Player.Name
                Jail.Parent = self.API.AdminItemContainer
                
                local Bottom = Instance.new("Part")
                Bottom.FormFactor = "Custom"
                Bottom.Size = Vector3.new(5.2,1,5.2)
                Bottom.Anchored = true
                Bottom.TopSurface = "Smooth"
                Bottom.TopSurface = "Smooth"
                Bottom.Material = "SmoothPlastic"
                Bottom.BrickColor = BrickColor.new("Black")
                Bottom.CFrame = Center * CFrame.new(0,-3.4,0)
                Bottom.Parent = Jail
                
                local Top = Instance.new("Part")
                Top.FormFactor = "Custom"
                Top.Size = Vector3.new(5.2,1,5.2)
                Top.Anchored = true
                Top.TopSurface = "Smooth"
                Top.TopSurface = "Smooth"
                Top.Material = "SmoothPlastic"
                Top.BrickColor = BrickColor.new("Black")
                Top.CFrame = Center * CFrame.new(0,3.6,0)
                Top.Parent = Jail
                
                local Front = Instance.new("Part")
                Front.FormFactor = "Custom"
                Front.Size = Vector3.new(5.2,6,0.6)
                Front.Anchored = true
                Front.TopSurface = "Smooth"
                Front.TopSurface = "Smooth"
                Front.Material = "SmoothPlastic"
                Front.BrickColor = BrickColor.new("White")
                Front.CFrame = Center * CFrame.new(0,0.1,2.3)
                Front.Transparency = 1
                Front.Parent = Jail
                
                local Back = Instance.new("Part")
                Back.FormFactor = "Custom"
                Back.Size = Vector3.new(5.2,6,0.6)
                Back.Anchored = true
                Back.TopSurface = "Smooth"
                Back.TopSurface = "Smooth"
                Back.Material = "SmoothPlastic"
                Back.BrickColor = BrickColor.new("White")
                Back.CFrame = Center * CFrame.new(0,0.1,-2.3)
                Back.Transparency = 1
                Back.Parent = Jail
                
                local Left = Instance.new("Part")
                Left.FormFactor = "Custom"
                Left.Size = Vector3.new(0.6,6,4)
                Left.Anchored = true
                Left.TopSurface = "Smooth"
                Left.TopSurface = "Smooth"
                Left.Material = "SmoothPlastic"
                Left.BrickColor = BrickColor.new("White")
                Left.CFrame = Center * CFrame.new(2.3,0.1,0)
                Left.Transparency = 1
                Left.Parent = Jail
                
                local Right = Instance.new("Part")
                Right.FormFactor = "Custom"
                Right.Size = Vector3.new(0.6,6,4)
                Right.Anchored = true
                Right.TopSurface = "Smooth"
                Right.TopSurface = "Smooth"
                Right.Material = "SmoothPlastic"
                Right.BrickColor = BrickColor.new("White")
                Right.CFrame = Center * CFrame.new(-2.3,0.1,0)
                Right.Transparency = 1
                Right.Parent = Jail
                
                local OuterGlass = Instance.new("Part")
                OuterGlass.FormFactor = "Custom"
                OuterGlass.Size = Vector3.new(2,2,2)
                OuterGlass.Anchored = true
                OuterGlass.CanCollide = false
                OuterGlass.TopSurface = "Smooth"
                OuterGlass.TopSurface = "Smooth"
                OuterGlass.Material = "SmoothPlastic"
                OuterGlass.BrickColor = BrickColor.new("White")
                OuterGlass.CFrame = Center * CFrame.new(0,0.1,0)
                OuterGlass.Transparency = 0.5
                OuterGlass.Parent = Jail
                
                local Mesh = Instance.new("SpecialMesh")
                Mesh.MeshType = "FileMesh"
                Mesh.MeshId = "http://www.roblox.com/Asset/?id=9856898"
                Mesh.Scale = Vector3.new(10.4,12,10.4)
                Mesh.Parent = OuterGlass
                
                local InnerGlass = Instance.new("Part")
                InnerGlass.FormFactor = "Custom"
                InnerGlass.Size = Vector3.new(2,2,2)
                InnerGlass.Anchored = true
                InnerGlass.CanCollide = false
                InnerGlass.TopSurface = "Smooth"
                InnerGlass.TopSurface = "Smooth"
                InnerGlass.Material = "SmoothPlastic"
                InnerGlass.BrickColor = BrickColor.new("White")
                InnerGlass.CFrame = Center * CFrame.new(0,0.1,0)
                InnerGlass.Transparency = 0.5
                InnerGlass.Parent = Jail
                
                local Mesh = Instance.new("SpecialMesh")
                Mesh.MeshType = "FileMesh"
                Mesh.MeshId = "http://www.roblox.com/Asset/?id=9856898"
                Mesh.Scale = Vector3.new(-8,-13,1-8)
                Mesh.Parent = InnerGlass
                
                --Connect the event.
                local CharacterAddedEvent = Player.CharacterAdded:Connect(function(Character)
                    if Jail.Parent then
                        local Root = Character:WaitForChild("HumanoidRootPart")
                        wait()
                        Root.CFrame = Center
                    end
                end)

                --Add the psuedo-object.
                local JailObject = {}
                JailObject.Jail = Jail
                JailObject.CharacterAddedEvent = CharacterAddedEvent
                function JailObject:Destroy()
                    self.Jail:Destroy()
                    self.CharacterAddedEvent:Disconnect()
                    CommonState.PlayerJails[Player] = nil
                end
                CommonState.PlayerJails[Player] = JailObject
            end
        end
    end
end



return Command