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
    self:InitializeSuper("fogcolor","BuildUtility","Sets the fog color.")

    self.Arguments = {
		{
			Type = "color3",
			Name = "FogColor",
			Description = "Fog color to set.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,FogColor)
	self.super:Run(CommandContext)
	
    --Set the fog color.
    if not CommonState.LightingProperties.FogColor then
        CommonState.LightingProperties.FogColor = self.Lighting.FogColor
    end
    self.Lighting.FogColor = FogColor
end



return Command