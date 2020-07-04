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
    self:InitializeSuper("jump","UsefulFunCommands","Jumps a set of players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to jump.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
	self.super:Run(CommandContext)

    --Jump the players.
    for _,Player in pairs(Players) do
        if Player.Character then
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.Jump = true
            end
        end
    end
end



return Command