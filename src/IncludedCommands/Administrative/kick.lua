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
    self:InitializeSuper("kick","Administrative","Kicks players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to kick.",
        },
        {
            Type = "string",
            Name = "Message",
            Description = "Kick message message.",
            Optional = true,
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Message)
    self.super:Run(CommandContext)

    --Kick the players.
    local ExecutorAdminLevel = self.API.Authorization:GetAdminLevel(CommandContext.Executor)
    for _,Player in pairs(Players) do
        if Player ~= CommandContext.Executor then
            if self.API.Authorization:GetAdminLevel(Player) < ExecutorAdminLevel then
                Player:Kick(Message)
            else
                self:SendError("You can't kick admins with higher levels than you.")
            end
        else
            self:SendError("You can't kick yourself.")
        end
    end
end



return Command