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
    self:InitializeSuper("outdoorambient","BuildUtility","Sets the outdoor ambient.")

    self.Arguments = {
		{
			Type = "color3",
			Name = "OutdoorAmbient",
			Description = "OutdoorAmbient to set.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,OutdoorAmbient)
	self.super:Run(CommandContext)
	
    --Set the outdoor ambient.
    if not CommonState.LightingProperties.OutdoorAmbient then
        CommonState.LightingProperties.OutdoorAmbient = self.Lighting.OutdoorAmbient
    end
    self.Lighting.OutdoorAmbient = OutdoorAmbient
end



return Command