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
    self:InitializeSuper("unvibrate","FunCommands","Unvibrates a set of players.")
    
    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to unvibrate.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Stop the vibrating.
    for _,Player in pairs(Players) do
        if CommonState.PlayerVibrations[Player] then
            CommonState.PlayerVibrations[Player]:Destroy()
        end
    end
end



return Command