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
    self:InitializeSuper("usage","Administrative","Displays the usage information of Nexus Admin.")

    self.Prefix = {"!",self.API.Configuration.CommandPrefix}
end



return Command