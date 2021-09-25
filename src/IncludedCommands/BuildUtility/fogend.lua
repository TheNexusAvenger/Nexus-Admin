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
    self:InitializeSuper("fogend","BuildUtility","Sets the fog end.")

    self.Arguments = {
        {
            Type = "number",
            Name = "FogEnd",
            Description = "Fog start to set.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,FogEnd)
    self.super:Run(CommandContext)
    
    --Set the fog end.
    if not CommonState.LightingProperties.FogEnd then
        CommonState.LightingProperties.FogEnd = self.Lighting.FogEnd
    end
    self.Lighting.FogEnd = FogEnd
end



return Command