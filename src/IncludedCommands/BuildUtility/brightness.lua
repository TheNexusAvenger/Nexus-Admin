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
    self:InitializeSuper("brightness","BuildUtility","Sets the brightness.")

    self.Arguments = {
		{
			Type = "number",
			Name = "Brightness",
			Description = "Brightness to set.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Brightness)
	self.super:Run(CommandContext)
	
    --Set the brightness.
    if not CommonState.LightingProperties.Brightness then
        CommonState.LightingProperties.Brightness = self.Lighting.Brightness
    end
    self.Lighting.Brightness = Brightness
end



return Command