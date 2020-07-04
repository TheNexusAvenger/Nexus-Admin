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
    self:InitializeSuper("ambient","BuildUtility","Sets the ambient.")

    self.Arguments = {
		{
			Type = "color3",
			Name = "Ambient",
			Description = "Ambient to set.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Ambient)
	self.super:Run(CommandContext)
	
    --Set the ambient.
    if not CommonState.LightingProperties.Ambient then
        CommonState.LightingProperties.Ambient = self.Lighting.Ambient
    end
    self.Lighting.Ambient = Ambient
end



return Command