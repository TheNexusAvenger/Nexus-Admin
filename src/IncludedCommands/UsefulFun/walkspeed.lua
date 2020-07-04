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
    self:InitializeSuper({"walkspeed","speed"},"UsefulFunCommands","Sets the walkspeeds of the given players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to set the walkspeed.",
		},
		{
			Type = "number",
			Name = "Walkspeed",
			Description = "Walkspeed to set.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,WalkSpeed)
	self.super:Run(CommandContext)
	
    --Set the walkspeed.
    for _,Player in pairs(Players) do
        local Character = Player.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = WalkSpeed
            end
        end
    end
end



return Command