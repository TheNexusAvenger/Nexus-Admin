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
    self:InitializeSuper("tpto","UsefulFunCommands","Teleports a set of players to a specific location.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to teleport.",
        },
        {
            Type = "vector3",
            Name = "TargetPosition",
            Description = "Position to teleport to.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,TargetPosition)
    self.super:Run(CommandContext)

    --Telelport the players.
    local Radius = math.max(10,#Players)
    local TargetLocation = CFrame.new(TargetPosition)
    if TargetLocation then
        for _,Player in pairs(Players) do
            self:TeleportPlayer(Player,TargetLocation * CFrame.new(math.random(-Radius,Radius)/10,0,math.random(-Radius,Radius)/10))
        end
    end
end



return Command