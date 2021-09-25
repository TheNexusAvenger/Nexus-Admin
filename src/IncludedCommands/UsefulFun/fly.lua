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
    self:InitializeSuper("fly","UsefulFunCommands","Gives a set of players the ability to fly. Use E to toggle on/off.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to fly.",
        },
    }
    
    --Create the remote event.
    local FlyPlayerEvent = Instance.new("RemoteEvent")
    FlyPlayerEvent.Name = "FlyPlayer"
    FlyPlayerEvent.Parent = self.API.EventContainer
    self.FlyPlayerEvent = FlyPlayerEvent
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Fling the players.
    for _,Player in pairs(Players) do
        self.FlyPlayerEvent:FireClient(Player)
    end
end



return Command