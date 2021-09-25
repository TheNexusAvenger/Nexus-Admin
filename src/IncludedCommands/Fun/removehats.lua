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
    self:InitializeSuper("removehats","FunCommands","Removes the hats of a set of players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to remove the hats of.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Remove the hats.
    for _,Player in pairs(Players) do
        if Player.Character then
            for _,Hat in pairs(Player.Character:GetChildren()) do
                if Hat:IsA("Hat") or Hat:IsA("Accoutrement") or Hat:IsA("Accessory") then
                    Hat:Destroy()
                end
            end
        end
    end
end



return Command