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
    self:InitializeSuper("unkeybind","Administrative","Unbinds the key from all commands.")

    self.Prefix = {"!",self.API.Configuration.CommandPrefix}
    self.Arguments = {
        {
            Type = "userInput",
            Name = "Key",
            Description = "Key to bind.",
        },
    }
end



return Command