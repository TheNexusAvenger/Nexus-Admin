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
    self:InitializeSuper("volume","FunCommands","Changes the volume of the audio.")

    self.Arguments = {
        {
            Type = "number",
            Name = "Volume",
            Description = "Volume to set.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Volume)
    self.super:Run(CommandContext)
    
    CommonState.GlobalAudio.Volume = Volume
end



return Command