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
    self:InitializeSuper("health","UsefulFunCommands","Heals a set of players, and sets their max health.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to set the health.",
        },
        {
            Type = "number",
            Name = "Health",
            Description = "Health to set.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Health)
    self.super:Run(CommandContext)
    
    --Set the max helath.
    for _,Player in pairs(Players) do
        local Character = Player.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.MaxHealth = Health
                Humanoid.Health = Health
            end
        end
    end
end



return Command