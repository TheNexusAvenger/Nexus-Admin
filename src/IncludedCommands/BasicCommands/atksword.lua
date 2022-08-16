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
    self:InitializeSuper("atksword","BasicCommands","Gives an anti-teamkill sword to the given players.")
    
    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give swords.",
        },
    }
    self.API.FeatureFlags:AddFeatureFlag("AllowDroppingSwords", true)
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
            local NewSword = Sword:Clone()
            NewSword.CanBeDropped = self.API.FeatureFlags:GetFeatureFlag("AllowDroppingSwords")
            NewSword:WaitForChild("Configurations"):WaitForChild("CanTeamkill").Value = false
            NewSword.Parent = Backpack
        end
    end
end



return Command