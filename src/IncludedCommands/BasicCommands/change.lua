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
    self:InitializeSuper("change","BasicCommands","Changes the stat of a set of players.")
    
    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to reset the stats for.",
        },
        {
            Type = "strings",
            Name = "Stats",
            Description = "Stats to change.",
        },
        {
            Type = "string",
            Name = "Value",
            Description = "Value to change to.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Stats,Value)
    self.super:Run(CommandContext)
    
    --Reset the stats.
    for _,Player in pairs(Players) do
        local leaderstats = Player:FindFirstChild("leaderstats")
        if leaderstats then
            for _,Stat in pairs(leaderstats:GetChildren()) do
                for _,StatName in pairs(Stats) do
                    StatName = string.lower(StatName)
                    if string.sub(string.lower(Stat.Name),1,string.len(StatName)) == StatName then
                        if type(Stat.Value) == "string" then
                            Stat.Value = Value
                        elseif type(Stat.Value) == "number" then
                            Stat.Value = tonumber(Value) or Stat.Value
                        else
                            self:SendError(Player,"Unable to assign value to stat.")
                        end
                    end
                end
            end
        end
    end
end



return Command