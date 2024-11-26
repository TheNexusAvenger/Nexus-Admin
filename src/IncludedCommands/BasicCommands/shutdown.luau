--Implementation of a command.
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "shutdown",
    Category = "BasicCommands",
    Description = "Shuts down the server.",
    ServerRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        --Display the server is shutting down.
        for _,Player in Players:GetPlayers() do
            Api.Messages:DisplayMessage(Player, "Nexus Admin", "Server is shutting down.")
        end
        task.wait(1)

        --Kick the players.
        for _,Player in Players:GetPlayers() do
            Player:Kick("Server has shut down.")
        end
        Players.PlayerAdded:Connect(function(Player)
            Player:Kick("Server has shut down.")
        end)
    end,
}