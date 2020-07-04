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
    self:InitializeSuper("alias","Administrative","Creates a new, single command out of a command and given arguments. (Reimplmented for Nexus Admin)")

    self.Arguments = {
        {
            Type = "string";
            Name = "Name";
            Description = "The key or input type you'd like to bind the command to."
        },
        {
            Type = "string";
            Name = "Command";
            Description = "The command text you want to run. Separate multiple commands with \"&&\". Accept arguments with $1, $2, $3, etc."
        },
    }
end



return Command