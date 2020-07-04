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
    self:InitializeSuper({"slock","serverlock"},"Administrative","Locks and unlocks the server for non-admins.")

    self.Arguments = {
		{
			Type = "boolean",
			Name = "Active",
            Description = "Whether the server lock is active or not.",
            Optional = true,
		},
    }
    
    --Connect kicking players on entry.
    self.ServerLocked = false
    self.Players.PlayerAdded:Connect(function(Player)
        if self.ServerLocked and self.API.Authorization:YieldForAdminLevel(Player) < 0 then
            Player:Kick("Server was locked by an admin. Please try again later.")
            for _,Admin in pairs(self.Players:GetPlayers()) do
				if self.API.Authorization:GetAdminLevel(Admin) >= 0 then
					self.API.Messages:DisplayHint(Admin,Player.Name.." ("..Player.UserId..") tried to enter the server.")
				end
			end
        end
    end)
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Active)
    self.super:Run(CommandContext)

    --Set the server lock.
    if Active ~= nil then
        self.ServerLocked = Active
    else
        self.ServerLocked = not self.ServerLocked
    end

    --Display a message.
    if self.ServerLocked then
        return "Server has been locked."
    else
        return "Server has been unlocked."
    end
end



return Command