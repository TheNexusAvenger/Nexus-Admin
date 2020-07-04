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
    self:InitializeSuper("pause","FunCommands","Pauses the audio.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
	self.super:Run(CommandContext)
    
    CommonState.GlobalAudio:Pause()
end



return Command