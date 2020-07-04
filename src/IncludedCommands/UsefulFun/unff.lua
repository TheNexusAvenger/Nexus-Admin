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
    self:InitializeSuper("unff","UsefulFunCommands","Removes all force fields from the given players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to remove force fields from.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
	self.super:Run(CommandContext)
	
    --Give the forcefields.
    for _,Player in pairs(Players) do
        local Character = Player.Character
        if Character then
            for _,Ins in pairs(Character:GetChildren()) do
                if Ins:IsA("ForceField") then
                    Ins:Destroy()
                end
            end
        end
    end
end



return Command