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
    self:InitializeSuper("keybinds","Administrative","Displays the current keybinds.")

    self.Prefix = {"!",self.API.Configuration.CommandPrefix}
end



return Command