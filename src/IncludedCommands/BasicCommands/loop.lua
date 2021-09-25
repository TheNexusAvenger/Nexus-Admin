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
    self:InitializeSuper("loop","BasicCommands","Loops a command for a certain amount of times with a certain interval.")

    self.Arguments = {
        {
            Type = "integer",
            Name = "Times",
            Description = "Times to run the command.",
        },
        {
            Type = "number",
            Name = "Delay",
            Description = "Delay between rerunning the command.",
        },
        {
            Type = "string",
            Name = "Command",
            Description = "Command to run.",
        },
    }
end



return Command