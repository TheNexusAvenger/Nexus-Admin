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
    self:InitializeSuper("place","UsefulFunCommands","Teleports a set of players to the given place.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to teleport.",
        },
        {
            Type = "integer",
            Name = "PlaceId",
            Description = "Place to teleport to.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,PlaceId)
    self.super:Run(CommandContext)
    
    --Telelport the players.
    for _,Player in pairs(Players) do
        self.TeleportService:Teleport(PlaceId,Player)
    end
end



return Command