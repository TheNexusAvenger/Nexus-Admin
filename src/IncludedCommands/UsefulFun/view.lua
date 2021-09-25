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
    self:InitializeSuper("view","UsefulFunCommands","Views a given player.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Player",
            Description = "Player to view.",
        },
    }
end



return Command