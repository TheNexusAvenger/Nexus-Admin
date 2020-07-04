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
    self:InitializeSuper("removetools","BasicCommands","Removes all tools from the players given.")
    
    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to remove tools from.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Clear the tools.
    for _,Player in pairs(Players) do
        --Unequip the character.
        if Player.Character then
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:UnequipTools()
            end
        end

        --Clear the backback.
        local Backpack = Player:FindFirstChild("Backpack")
        if Backpack then
            for _,Tool in pairs(Backpack:GetChildren()) do
                if Tool:IsA("Tool") or Tool:IsA("HopperBin") then
                    Tool:Destroy()
                end
            end
        end
    end
end



return Command