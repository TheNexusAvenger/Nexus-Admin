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
    self:InitializeSuper("crash","BasicCommands","Crashes a set of players. Admins can not be crashed.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to crash.",
        },
    }
    
    --Create the remote event.
    local CrashPlayerEvent = Instance.new("RemoteEvent")
    CrashPlayerEvent.Name = "CrashPlayer"
    CrashPlayerEvent.Parent = self.API.EventContainer
    self.CrashPlayerEvent = CrashPlayerEvent
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Crash the players.
    for _,Player in pairs(Players) do
        if self.API.Authorization:GetAdminLevel(Player) >= 0 then
            self:SendError("You can't crash admins.")
        else
            self.CrashPlayerEvent:FireClient(Player)
        end
    end
end



return Command