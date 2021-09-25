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
    self:InitializeSuper("keybind","Administrative","Binds the key with a specified command.")

    self.Prefix = {"!",self.API.Configuration.CommandPrefix}
    self.Arguments = {
        {
            Type = "userInput",
            Name = "Key",
            Description = "Key to bind.",
        },
        {
            Type = "string",
            Name = "Command",
            Description = "Command to run.",
        },
    }
end



return Command