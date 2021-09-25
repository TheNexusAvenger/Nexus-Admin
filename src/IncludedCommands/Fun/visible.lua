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
    self:InitializeSuper("visible","FunCommands","Makes a set of players visible.")
    
    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to make visible.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Show the players.
    for _,Player in pairs(Players) do
        if Player.Character then
            for _,Ins in pairs(Player.Character:GetDescendants()) do
                if (Ins:IsA("BasePart") or Ins:IsA("Decal")) and Ins.Transparency > 1 then
                    Ins.Transparency = Ins.Transparency - 1.1
                end
            end
        end
    end
end



return Command