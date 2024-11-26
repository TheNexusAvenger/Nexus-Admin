--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unblind",
    Category = "FunCommands",
    Description = "Unblinds a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unblind.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            local PlayerGui = Player:FindFirstChild("PlayerGui")
            if PlayerGui then
                if PlayerGui:FindFirstChild("NexusAdminBlind") then
                    (PlayerGui:FindFirstChild("NexusAdminBlind") :: ScreenGui):Destroy()
                end
            end
        end
    end,
}