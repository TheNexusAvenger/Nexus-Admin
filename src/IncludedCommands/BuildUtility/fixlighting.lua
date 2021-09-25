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
    self:InitializeSuper("fixlighting","BuildUtility","Reverts the lighting changed by the admin.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,TimeOfDay)
    self.super:Run(CommandContext)
    
    --Revert the settings.
    for Key,Value in pairs(CommonState.LightingProperties) do
        self.Lighting[Key] = Value
    end
    CommonState.LightingProperties = {}
end



return Command