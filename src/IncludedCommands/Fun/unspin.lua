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
    self:InitializeSuper("unspin","FunCommands","Unspins a set of players.")
    
    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to unspin.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Remove the spin effects.
    for _,Player in pairs(Players) do
        if Player.Character then
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                local BodyAngularVelocity = HumanoidRootPart:FindFirstChild("NexusAdminSpinEffect")
                if BodyAngularVelocity then
                    BodyAngularVelocity:Destroy()
                end
            end
        end
    end
end



return Command