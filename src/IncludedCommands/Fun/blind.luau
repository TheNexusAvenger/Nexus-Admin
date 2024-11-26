--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "blind",
    Category = "FunCommands",
    Description = "Blinds a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to blind.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            local PlayerGui = Player:FindFirstChild("PlayerGui")
            if PlayerGui then
                if not PlayerGui:FindFirstChild("NexusAdminBlind") then
                    local NexusAdminBlind = Instance.new("ScreenGui")
                    NexusAdminBlind.Name = "NexusAdminBlind"
                    NexusAdminBlind.Parent = PlayerGui
                    
                    local Frame = Instance.new("Frame")
                    Frame.Size = UDim2.new(3, 0, 3, 0)
                    Frame.Position = UDim2.new(-1, 0, -1, 0)
                    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    Frame.BorderSizePixel = 0
                    Frame.Parent = NexusAdminBlind
                end
            end
        end
    end,
}