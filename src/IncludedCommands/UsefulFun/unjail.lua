--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local CommonState = require(script.Parent.Parent:WaitForChild("CommonState"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("unjail","UsefulFunCommands","Unjails a set of players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to unjail.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
	self.super:Run(CommandContext)
	
    --Destroy the jails.
    for _,Player in pairs(Players) do
        if CommonState.PlayerJails[Player] then
            CommonState.PlayerJails[Player]:Destroy()
        end
    end
end



return Command