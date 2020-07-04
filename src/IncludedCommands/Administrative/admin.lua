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
    self:InitializeSuper("admin","Administrative","Sets the admin level of players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to change the admin level of.",
		},
		{
			Type = "number",
			Name = "Value",
            Description = "Admin level to use.",
            Optional = true,
            Default = 1,
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,AdminLevel)
    self.super:Run(CommandContext)
    
    --Return if the admin level is higher than the player's admin level.
    local ExecutorAdminLevel = self.API.Authorization:GetAdminLevel(CommandContext.Executor)
    if AdminLevel >= ExecutorAdminLevel then
        return "You can't set admin levels higher than yours."
    end

    --Set the admin levels.
    for _,Player in pairs(Players) do
        if Player ~= CommandContext.Executor then
            if self.API.Authorization:GetAdminLevel(Player) < ExecutorAdminLevel then
                self.API.Authorization:SetAdminLevel(Player,AdminLevel)
            else
                self:SendError("You can't change admins with higher levels than you.")
            end
        else
            self:SendError("You can't change your own admin level.")
        end
    end
end



return Command