--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))
local ToolListEnum = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ToolListEnum"))

return {
    Keyword = "give",
    Category = "BasicCommands",
    Description = "Gives a set of players tools matching the tool name(s) from Lighting, ReplicatedStorage, ServerStorage, or StarterPack.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give tools.",
        },
        {
            Type = "nexusAdminTools",
            Name = "Tools",
            Description = "Tools to give.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, ToolNames: {string})
        --Give the tools.
        for _, Tool in ToolListEnum:GetTools(ToolNames) do
            for _, Player in pairs(Players) do
                local Backpack = Player:FindFirstChild("Backpack")
                if Backpack then
                    Tool:Clone().Parent = Backpack
                end
            end
        end
    end
}