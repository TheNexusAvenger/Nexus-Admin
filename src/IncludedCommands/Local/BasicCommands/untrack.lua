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
    self:InitializeSuper("untrack","BasicCommands","Untracks a set of players")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to untrack.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)

    --Destroy the trackers.
    for _,Player in pairs(Players) do
        if CommonState.PlayerTrackers[Player] then
            CommonState.PlayerTrackers[Player]:Destroy()
        end
    end
end



return Command