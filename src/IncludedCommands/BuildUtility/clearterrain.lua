--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("clearterrain","BuildUtility","Clears the terrain.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Team)
    self.super:Run(CommandContext)
    
    --Clear the terrain.
    self.Workspace.Terrain:Clear()
end



return Command