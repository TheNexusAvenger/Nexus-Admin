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
    self:InitializeSuper("name","UsefulFunCommands","Changes the name for a player.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to set the name.",
		},
		{
			Type = "string",
			Name = "Name",
			Description = "Name to set.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Name)
	self.super:Run(CommandContext)
	
    --Set the names.
    Name = self.API.Filter:FilterString(Name,CommandContext.Executor)
    for _,Player in pairs(Players) do
        local Character = Player.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.DisplayName = Name
            end
        end
    end
end



return Command