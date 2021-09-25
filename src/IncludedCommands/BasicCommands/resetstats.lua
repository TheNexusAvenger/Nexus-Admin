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
    self:InitializeSuper("resetstats","BasicCommands","Resets all number leaderstats of a player.")
    
    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to reset the stats for.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Reset the stats.
    for _,Player in pairs(Players) do
        local leaderstats = Player:FindFirstChild("leaderstats")
        if leaderstats then
            for _,Stat in pairs(leaderstats:GetChildren()) do
                if Stat:IsA("ValueBase") and type(Stat.Value) == "number" then
                    Stat.Value = 0
                end
            end
        end
    end
end



return Command