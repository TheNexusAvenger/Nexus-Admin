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
    self:InitializeSuper("damage","UsefulFunCommands","Damages a given set of players, ignoring force fields.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to kill.",
        },
        {
            Type = "number",
            Name = "Damage",
            Description = "Amount of damage.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Damage)
    self.super:Run(CommandContext)
    
    --Damage the players.
    for _,Player in pairs(Players) do
        local Character = Player.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.Health = Humanoid.Health - Damage
            end
        end
    end
end



return Command