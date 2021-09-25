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
    self:InitializeSuper("fogstart","BuildUtility","Sets the fog start.")

    self.Arguments = {
        {
            Type = "number",
            Name = "FogStart",
            Description = "Fog start to set.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,FogStart)
    self.super:Run(CommandContext)
    
    --Set the fog start.
    if not CommonState.LightingProperties.FogStart then
        CommonState.LightingProperties.FogStart = self.Lighting.FogStart
    end
    self.Lighting.FogStart = FogStart
end



return Command