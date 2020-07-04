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
    self:InitializeSuper("hat","FunCommands","Gives hats to the given players.")
    
    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to give hats.",
		},
		{
			Type = "integers",
			Name = "Ids",
			Description = "Hats ids to insert.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Ids)
    self.super:Run(CommandContext)
    
    --Get the hats.
    local Hats = {}
    for _,Id in pairs(Ids) do
        local Model = self.InsertService:LoadAsset(Id)
        for _,Hat in pairs(Model:GetChildren()) do
            if Hat:IsA("Hat") or Hat:IsA("Accoutrement") or Hat:IsA("Accessory") then
                table.insert(Hats,Hat)
            end
        end
    end

    --Give the hats to the players.
    for _,Player in pairs(Players) do
        if Player.Character then
            for _,Hat in pairs(Hats) do
                Hat:Clone().Parent = Player.Character
            end
        end
    end
end



return Command