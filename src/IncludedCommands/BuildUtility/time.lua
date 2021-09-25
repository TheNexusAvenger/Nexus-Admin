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
    self:InitializeSuper("time","BuildUtility","Sets the time of day.")

    self.Arguments = {
        {
            Type = "string",
            Name = "Time",
            Description = "Time of day to set.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,TimeOfDay)
    self.super:Run(CommandContext)
    
    --Set the time.
    if not CommonState.LightingProperties.TimeOfDay then
        CommonState.LightingProperties.TimeOfDay = self.Lighting.TimeOfDay
    end
    self.Lighting.TimeOfDay = TimeOfDay
end



return Command