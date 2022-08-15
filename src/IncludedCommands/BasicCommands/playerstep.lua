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
    self:InitializeSuper("playerstep", "BasicCommands", "Runs a command for a given set of players, but one at a time with a GUI to continue to the next player.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to run the command one.",
        },
        {
            Type = "string",
            Name = "Command",
            Description = "Command to run on the players. Use {player} for any place where the player should be inputted.",
        },
    }
end



return Command