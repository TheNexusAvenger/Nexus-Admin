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
    self:InitializeSuper("kill","UsefulFunCommands","Kills a given set of players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to kill.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Name)
    self.super:Run(CommandContext)
    
    --Kill the players.
    for _,Player in pairs(Players) do
        local Character = Player.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.Health = 0
            end
        end
    end
end



return Command