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
    self:InitializeSuper("removeteam","BasicCommands","Removes selected teams.")

    self.Arguments = {
        {
            Type = "teams",
            Name = "Teams",
            Description = "Teams to remove.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Teams)
    self.super:Run(CommandContext)
    
    --Remove the teams.
    for _,Team in pairs(Teams) do
        Team:Destroy()
    end
end



return Command