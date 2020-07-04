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
    self:InitializeSuper("stoploops","BasicCommands","Stops all active loop commands.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)

    --Stop and unregister the loops.
    for _,Loop in pairs(CommonState.Loops) do
        Loop:Stop()
    end
    CommonState.Loops = {}
end



return Command