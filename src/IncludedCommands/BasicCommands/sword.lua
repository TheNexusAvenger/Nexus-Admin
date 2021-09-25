--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Sword = script.Parent.Parent:WaitForChild("Resources"):WaitForChild("Sword")
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("sword","BasicCommands","Gives a sword to the given players.")
    
    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give swords.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Give the swords.
    for _,Player in pairs(Players) do
        local Backpack = Player:FindFirstChild("Backpack")
        if Backpack then
            Sword:Clone().Parent = Backpack
        end
    end
end



return Command