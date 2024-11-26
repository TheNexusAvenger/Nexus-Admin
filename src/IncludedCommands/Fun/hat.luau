--Implementation of a command.
--!strict

local InsertService = game:GetService("InsertService")

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "hat",
    Category = "FunCommands",
    Description = "Gives hats to the given players.",
    Arguments = {
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
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Ids: {number})
        --Insert the hats.
        local Hats = {}
        for _,Id in Ids do
            local Model = InsertService:LoadAsset(Id)
            for _, Hat in pairs(Model:GetChildren()) do
                if Hat:IsA("Hat") or Hat:IsA("Accoutrement") or Hat:IsA("Accessory") then
                    table.insert(Hats, Hat)
                end
            end
        end

        --Give the hats to the players.
        for _,Player in Players do
            if Player.Character then
                for _, Hat in Hats do
                    Hat:Clone().Parent = Player.Character
                end
            end
        end
    end,
}