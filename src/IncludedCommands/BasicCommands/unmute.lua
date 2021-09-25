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
    self:InitializeSuper("unmute","BasicCommands","Unmutes a set of players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unmute.",
        },
    }
    
    --Create the remote event.
    local UnmutePlayerEvent = Instance.new("RemoteEvent")
    UnmutePlayerEvent.Name = "UnmutePlayer"
    UnmutePlayerEvent.Parent = self.API.EventContainer
    self.UnmutePlayerEvent = UnmutePlayerEvent
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Mute the players.
    for _,Player in pairs(Players) do
        self.UnmutePlayerEvent:FireClient(Player)
    end
end



return Command