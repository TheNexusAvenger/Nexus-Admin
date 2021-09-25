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
    self:InitializeSuper("delay","BasicCommands","Runs a command after a given amount of seconds.")

    self.Arguments = {
        {
            Type = "number",
            Name = "Delay",
            Description = "Delay before running the command.",
        },
        {
            Type = "string",
            Name = "Command",
            Description = "Command to run.",
        },
    }
end



return Command