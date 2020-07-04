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
    self:InitializeSuper("flip","UsefulFunCommands","Flips a set of players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to flip.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
	self.super:Run(CommandContext)

    --Flip the players.
    for _,Player in pairs(Players) do
        if Player.Character then
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0,0,math.pi)
            end
        end
    end
end



return Command