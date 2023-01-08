--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "removetools",
    Category = "BasicCommands",
    Description = "Removes all tools from the players given.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to remove tools from.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
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
                for _, Tool in Backpack:GetChildren() do
                    if Tool:IsA("BackpackItem") then
                        Tool:Destroy()
                    end
                end
            end
        end
    end,
}