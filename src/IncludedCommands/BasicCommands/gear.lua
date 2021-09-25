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
    self:InitializeSuper("gear","BasicCommands","Gives gear items to the given players.")
    
    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give the gear.",
        },
        {
            Type = "integers",
            Name = "Ids",
            Description = "Gear ids to insert.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Ids)
    self.super:Run(CommandContext)
    
    --Get the tools.
    local Tools = {}
    for _,Id in pairs(Ids) do
        local Model = self.InsertService:LoadAsset(Id)
        for _,Tool in pairs(Model:GetChildren()) do
            if Tool:IsA("Tool") then
                table.insert(Tools,Tool)
            end
        end
    end

    --Give the tools to the players.
    for _,Player in pairs(Players) do
        local Backpack = Player:FindFirstChild("Backpack")
        if Backpack then
            for _,Tool in pairs(Tools) do
                Tool:Clone().Parent = Backpack
            end
        end
    end
end



return Command