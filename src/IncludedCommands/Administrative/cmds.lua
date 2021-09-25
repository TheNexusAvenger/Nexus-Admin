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
    self:InitializeSuper({"cmds","commands","help"},"Administrative","Displays a list of all commands, or inspects one command.")

    self.Prefix = {"!",self.API.Configuration.CommandPrefix}
    self.Arguments = {
        {
            Type = "command";
            Name = "Command";
            Description = "The command to view information on (command line only)";
            Optional = true;
        },
    }
end



return Command