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
    self:InitializeSuper("team","BasicCommands","Changes a set of player's team to the given team.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to respawn.",
        },
        {
            Type = "team",
            Name = "Team",
            Description = "Team to set to.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Team)
    self.super:Run(CommandContext)
    
    --Set the team.
    for _,Player in pairs(Players) do
        Player.Team = Team
    end
end



return Command