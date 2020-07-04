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
    self:InitializeSuper({"grav","setgrav"},"UsefulFunCommands","Sets the gravity of a set of players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to change the gravity for.",
		},
		{
			Type = "number",
			Name = "Multiplier",
            Description = "Multiplifer of the gravity.",
            Optional = true,
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Multiplier)
    self.super:Run(CommandContext)
	
    --Set the gravity of the players.
    for _,Player in pairs(Players) do
        local Character = Player.Character
        if Character then
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                --Destroy the existing gravity effect.
                local NexusAdminGravityEffect = HumanoidRootPart:FindFirstChild("NexusAdminGravityEffect")
                if NexusAdminGravityEffect then
                    NexusAdminGravityEffect:Destroy()
                end

                if Multiplier and Multiplier ~= 1 then
                    --Calculate the gravity of the player.
                    local Mass = 0
                    for _,Ins in pairs(Character:GetDescendants()) do
                        if Ins:IsA("BasePart") then
                            Mass = Mass + (Ins:GetMass() * self.Workspace.Gravity)
                        end
                    end

                    --Create the gravity effect.
                    NexusAdminGravityEffect = Instance.new("BodyForce")
					NexusAdminGravityEffect.Name = "NexusAdminGravityEffect"
					NexusAdminGravityEffect.Force = Vector3.new(0,Mass * -(Multiplier - 1),0)
					NexusAdminGravityEffect.Parent = HumanoidRootPart
                end
            end
        end
    end
end



return Command