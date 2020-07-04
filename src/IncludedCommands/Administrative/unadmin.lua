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
    self:InitializeSuper("unadmin","Administrative","Unadmin players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to unadmin.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Set the admin levels.
    local ExecutorAdminLevel = self.API.Authorization:GetAdminLevel(CommandContext.Executor)
    for _,Player in pairs(Players) do
        if Player ~= CommandContext.Executor then
            if self.API.Authorization:GetAdminLevel(Player) < ExecutorAdminLevel then
                self.API.Authorization:SetAdminLevel(Player,-1)
            else
                self:SendError("You can't unadmin players with higher levels than you.")
            end
        else
            self:SendError("You can't unadmin yourself.")
        end
    end
end



return Command