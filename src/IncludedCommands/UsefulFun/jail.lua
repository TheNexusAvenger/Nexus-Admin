--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "jail",
    Category = "UsefulFunCommands",
    Description = "Creates a jail around a set of players. Each player can only have one jail.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to jail.",
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        Api.CommandData.PlayerJails = {}
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Create the jails.
        for _, Player in Players do
            local Character = Player.Character
            if not Api.CommandData.PlayerJails[Player] and Character then
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart
                if HumanoidRootPart then
                    --Create the jail.
                    local Center = HumanoidRootPart.CFrame
                    local Jail = Instance.new("Model")
                    Jail.Name = "Jail_"..Player.Name
                    Jail.Parent = Api.AdminItemContainer
                    
                    local Bottom = Instance.new("Part")
                    Bottom.Size = Vector3.new(5.2, 1, 5.2)
                    Bottom.Anchored = true
                    Bottom.Material = Enum.Material.SmoothPlastic
                    Bottom.BrickColor = BrickColor.new("Black")
                    Bottom.CFrame = Center * CFrame.new(0, -3.4, 0)
                    Bottom.Parent = Jail
                    
                    local Top = Instance.new("Part")
                    Top.Size = Vector3.new(5.2, 1, 5.2)
                    Top.Anchored = true
                    Top.Material = Enum.Material.SmoothPlastic
                    Top.BrickColor = BrickColor.new("Black")
                    Top.CFrame = Center * CFrame.new(0, 3.6, 0)
                    Top.Parent = Jail
                    
                    local Front = Instance.new("Part")
                    Front.Size = Vector3.new(5.2,6,0.6)
                    Front.Anchored = true
                    Front.Material = Enum.Material.SmoothPlastic
                    Front.BrickColor = BrickColor.new("White")
                    Front.CFrame = Center * CFrame.new(0, 0.1, 2.3)
                    Front.Transparency = 1
                    Front.Parent = Jail
                    
                    local Back = Instance.new("Part")
                    Back.Size = Vector3.new(5.2, 6, 0.6)
                    Back.Anchored = true
                    Back.Material = Enum.Material.SmoothPlastic
                    Back.BrickColor = BrickColor.new("White")
                    Back.CFrame = Center * CFrame.new(0, 0.1, -2.3)
                    Back.Transparency = 1
                    Back.Parent = Jail
                    
                    local Left = Instance.new("Part")
                    Left.Size = Vector3.new(0.6, 6, 4)
                    Left.Anchored = true
                    Left.Material = Enum.Material.SmoothPlastic
                    Left.BrickColor = BrickColor.new("White")
                    Left.CFrame = Center * CFrame.new(2.3, 0.1, 0)
                    Left.Transparency = 1
                    Left.Parent = Jail
                    
                    local Right = Instance.new("Part")
                    Right.Size = Vector3.new(0.6,6,4)
                    Right.Anchored = true
                    Right.Material = Enum.Material.SmoothPlastic
                    Right.BrickColor = BrickColor.new("White")
                    Right.CFrame = Center * CFrame.new(-2.3, 0.1, 0)
                    Right.Transparency = 1
                    Right.Parent = Jail
                    
                    local OuterGlass = Instance.new("Part")
                    OuterGlass.Size = Vector3.new(2, 2, 2)
                    OuterGlass.Anchored = true
                    OuterGlass.CanCollide = false
                    OuterGlass.Material = Enum.Material.SmoothPlastic
                    OuterGlass.BrickColor = BrickColor.new("White")
                    OuterGlass.CFrame = Center * CFrame.new(0, 0.1, 0)
                    OuterGlass.Transparency = 0.5
                    OuterGlass.Parent = Jail
                    
                    local OuterMesh = Instance.new("SpecialMesh")
                    OuterMesh.MeshType = Enum.MeshType.FileMesh
                    OuterMesh.MeshId = "http://www.roblox.com/Asset/?id=9856898"
                    OuterMesh.Scale = Vector3.new(10.4, 12, 10.4)
                    OuterMesh.Parent = OuterGlass
                    
                    local InnerGlass = Instance.new("Part")
                    InnerGlass.Size = Vector3.new(2, 2, 2)
                    InnerGlass.Anchored = true
                    InnerGlass.CanCollide = false
                    InnerGlass.Material = Enum.Material.SmoothPlastic
                    InnerGlass.BrickColor = BrickColor.new("White")
                    InnerGlass.CFrame = Center * CFrame.new(0, 0.1, 0)
                    InnerGlass.Transparency = 0.5
                    InnerGlass.Parent = Jail
                    
                    local InnerMesh = Instance.new("SpecialMesh")
                    InnerMesh.MeshType = Enum.MeshType.FileMesh
                    InnerMesh.MeshId = "http://www.roblox.com/Asset/?id=9856898"
                    InnerMesh.Scale = Vector3.new(-8, -13, -8)
                    InnerMesh.Parent = InnerGlass
                    
                    --Connect the event.
                    local CharacterAddedEvent = Player.CharacterAdded:Connect(function(Character)
                        if Jail.Parent then
                            local Root = Character:WaitForChild("HumanoidRootPart") :: BasePart
                            task.wait()
                            Root.CFrame = Center
                        end
                    end)

                    --Add the object.
                    local JailObject = {}
                    JailObject.Jail = Jail
                    JailObject.CharacterAddedEvent = CharacterAddedEvent
                    function JailObject:Destroy()
                        self.Jail:Destroy()
                        self.CharacterAddedEvent:Disconnect()
                        Api.CommandData.PlayerJails[Player] = nil
                    end
                    Api.CommandData.PlayerJails[Player] = JailObject
                end
            end
        end
    end,
}