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
    self:InitializeSuper({"thaw","unfreeze"},"UsefulFunCommands","Thaws the character of the given players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to thaw.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)

    --Thaw the players.
    for _,Player in pairs(Players) do
        if Player.Character then
            for _,Ins in pairs(Player.Character:GetDescendants()) do
                if Ins:IsA("BasePart") then
                    Ins.Anchored = false
                end
            end
        end
    end
end



return Command