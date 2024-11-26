--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))
local ToolListEnum = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ToolListEnum"))

return {
    Keyword = "startergive",
    Category = "BasicCommands",
    Description = "Gives a set of players tools matching the tool name(s) from Lighting, ReplicatedStorage, ServerStorage, or StarterPack and makes it so they spawn with them.",
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
        for _, Tool in ToolListEnum:GetTools(ToolNames) do
            for _, Player in Players do
                local Backpack = Player:FindFirstChild("Backpack")
                local StarterGear = Player:FindFirstChild("StarterGear")
                if Backpack then
                    Tool:Clone().Parent = Backpack
                end
                if StarterGear then
                    Tool:Clone().Parent = StarterGear
                end
            end
        end
    end,
}