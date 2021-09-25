--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local CommonState = require(script.Parent.Parent:WaitForChild("CommonState"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("shadows","BuildUtility","Toggles the shadows.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)
    
    --Set the shadows.
    if not CommonState.LightingProperties.GlobalShadows then
        CommonState.LightingProperties.GlobalShadows = self.Lighting.GlobalShadows
    end
    self.Lighting.GlobalShadows = not self.Lighting.GlobalShadows
end



return Command