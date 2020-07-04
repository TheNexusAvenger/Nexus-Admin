--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("rocket","FunCommands","Adds a rocket to a set of players.")
    
    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to give a rocket to.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Add the rockets.
    for _,Player in pairs(Players) do
        if Player.Character then
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart and not HumanoidRootPart:FindFirstChild("NexusAdminRocket") then
                local NexusAdminRocket = Instance.new("Part")
                NexusAdminRocket.Name = "NexusAdminRocket"
                NexusAdminRocket.Material = "SmoothPlastic"
                NexusAdminRocket.CanCollide = false
                NexusAdminRocket.Size = Vector3.new(1,2,2)
                NexusAdminRocket.Parent = HumanoidRootPart
                
                local Mesh = Instance.new("SpecialMesh")
                Mesh.MeshType = "FileMesh"
                Mesh.MeshId = "http://www.roblox.com/asset/?id=2251534"
                Mesh.Scale = Vector3.new(0.5,0.5,0.5)
                Mesh.Parent = NexusAdminRocket
                
                local Weld = Instance.new("Weld")
                Weld.Part0 = HumanoidRootPart
                Weld.Part1 = NexusAdminRocket
                Weld.C1 = CFrame.new(0,-0.8,0.4) * CFrame.Angles(-math.pi/2,0,0)
                Weld.Parent = NexusAdminRocket
                
                local Fire = Instance.new("Fire")
                Fire.Heat = 0
                Fire.Parent = NexusAdminRocket
                
                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(0,math.huge,0)
                BodyVelocity.Velocity = Vector3.new(0,75,0)
                BodyVelocity.Parent = NexusAdminRocket
            end
        end
    end
end



return Command