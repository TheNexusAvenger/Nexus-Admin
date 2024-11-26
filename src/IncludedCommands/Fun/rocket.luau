--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "rocket",
    Category = "FunCommands",
    Description = "Adds a rocket to a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give a rocket to.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart") :: Part
                if HumanoidRootPart and not HumanoidRootPart:FindFirstChild("NexusAdminRocket") then
                    local NexusAdminRocket = Instance.new("Part")
                    NexusAdminRocket.Name = "NexusAdminRocket"
                    NexusAdminRocket.Material = Enum.Material.SmoothPlastic
                    NexusAdminRocket.CanCollide = false
                    NexusAdminRocket.Size = Vector3.new(1, 2, 2)
                    NexusAdminRocket.Parent = HumanoidRootPart
                    
                    local Mesh = Instance.new("SpecialMesh")
                    Mesh.MeshType = Enum.MeshType.FileMesh
                    Mesh.MeshId = "rbxassetid://2251534"
                    Mesh.Scale = Vector3.new(0.5, 0.5, 0.5)
                    Mesh.Parent = NexusAdminRocket
                    
                    local Weld = Instance.new("Weld")
                    Weld.Part0 = HumanoidRootPart
                    Weld.Part1 = NexusAdminRocket
                    Weld.C1 = CFrame.new(0, -0.8, 0.4) * CFrame.Angles(-math.pi / 2, 0, 0)
                    Weld.Parent = NexusAdminRocket
                    
                    local Fire = Instance.new("Fire")
                    Fire.Heat = 0
                    Fire.Parent = NexusAdminRocket
                    
                    local BodyVelocity = Instance.new("BodyVelocity")
                    BodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
                    BodyVelocity.Velocity = Vector3.new(0, 75, 0)
                    BodyVelocity.Parent = NexusAdminRocket
                end
            end
        end
    end,
}