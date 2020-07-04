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
    self:InitializeSuper("cmdbar","Administrative","Brings up the command line. Alternative to pressing \\.")

    self.Prefix = {"!",self.API.Configuration.CommandPrefix}
end



return Command