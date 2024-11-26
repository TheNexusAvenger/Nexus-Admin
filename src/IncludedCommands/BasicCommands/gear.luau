--Implementation of a command.
--!strict

local InsertService = game:GetService("InsertService")

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "gear",
    Category = "BasicCommands",
    Description = "Gives gear items to the given players.",
    Arguments = {
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
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Ids: {number})
        --Get the tools.
        local Tools = {}
        for _, Id in Ids do
            local Model = InsertService:LoadAsset(Id)
            for _, Tool in Model:GetChildren() do
                if Tool:IsA("Tool") then
                    table.insert(Tools,Tool)
                end
            end
        end

        --Give the tools to the players.
        for _, Player in Players do
            local Backpack = Player:FindFirstChild("Backpack")
            if Backpack then
                for _, Tool in Tools do
                    Tool:Clone().Parent = Backpack
                end
            end
        end
    end,
}