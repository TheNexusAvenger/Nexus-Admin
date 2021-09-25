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
    self:InitializeSuper("unfly","UsefulFunCommands","Removes flight from a set of players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unfly.",
        },
    }
    
    --Create the remote event.
    local UnflyPlayerEvent = Instance.new("RemoteEvent")
    UnflyPlayerEvent.Name = "UnflyPlayer"
    UnflyPlayerEvent.Parent = self.API.EventContainer
    self.UnflyPlayerEvent = UnflyPlayerEvent
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Unfly the player.
    for _,Player in pairs(Players) do
        self.UnflyPlayerEvent:FireClient(Player)
    end
end



return Command