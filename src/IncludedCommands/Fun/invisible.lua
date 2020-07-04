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
    self:InitializeSuper("invisible","FunCommands","Makes a set of players invisible.")
    
    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to make invisible.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Hide the players.
    for _,Player in pairs(Players) do
        if Player.Character then
            for _,Ins in pairs(Player.Character:GetDescendants()) do
                if (Ins:IsA("BasePart") or Ins:IsA("Decal")) and Ins.Transparency <= 1 then
                    Ins.Transparency = Ins.Transparency + 1.1
                end
            end
        end
    end
end



return Command