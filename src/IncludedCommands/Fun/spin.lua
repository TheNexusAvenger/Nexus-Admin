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
    self:InitializeSuper("spin","FunCommands","Spins a set of players.")
    
    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to spin.",
		},
		{
			Type = "number",
			Name = "Speed",
            Description = "Speed to spin at.",
            Optional = true,
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Speed)
    self.super:Run(CommandContext)
    Speed = Speed or 1
    
    for _,Player in pairs(Players) do
        if Player.Character then
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                --Remove the existing spin effect.
                local BodyAngularVelocity = HumanoidRootPart:FindFirstChild("NexusAdminSpinEffect")
                if BodyAngularVelocity then
                    BodyAngularVelocity:Destroy()
                end

                --Add the new spin effect.
                BodyAngularVelocity = Instance.new("BodyAngularVelocity")
                BodyAngularVelocity.Name = "NexusAdminSpinEffect"
                BodyAngularVelocity.MaxTorque = Vector3.new(0,math.huge,0)
                BodyAngularVelocity.AngularVelocity = Vector3.new(0,8 * Speed,0)
                BodyAngularVelocity.Parent = HumanoidRootPart
            end
        end
    end
end



return Command