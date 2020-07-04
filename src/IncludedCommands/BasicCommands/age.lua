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
    self:InitializeSuper("age","BasicCommands","Displays the age of a set of players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to show the age of.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
	self.super:Run(CommandContext)
	
    --Send the ages.
    for _,Player in pairs(Players) do
        self:SendMessage(Player.Name.." ("..Player.UserId..") has the age of "..Player.AccountAge.." days.")
    end
end



return Command