--Implementation of a command.
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "joinlogs",
    Category = "BasicCommands",
    Description = "Opens up a window containing the logs of when players joined and left.",
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        --Create the logs.
        local JoinLogs = Api.Logs.new()
        Api.LogsRegistry:RegisterLogs("JoinLogs", JoinLogs, Api.Configuration:GetCommandAdminLevel("BasicCommands", "joinlogs"))
    
        --Connect the players.
        Players.PlayerAdded:Connect(function(Player)
            JoinLogs:Add(`[{Api.Time:GetTimeString()}]: {Player.DisplayName} ({Player.Name}, {Player.UserId}) joined.`)
        end)
        Players.PlayerRemoving:Connect(function(Player, ExitReason)
            JoinLogs:Add(`[{Api.Time:GetTimeString()}]: {Player.DisplayName} ({Player.Name}, {Player.UserId}) left ({ExitReason.Name}).`)
        end)
        for _, Player in Players:GetPlayers() do
            JoinLogs:Add(`[{Api.Time:GetTimeString()}]: {Player.DisplayName} ({Player.Name}, {Player.UserId}) was already in the server when Nexus Admin loaded.`)
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()
        
        --Show the window.
        local Window = Api.Window:CreateWindow("Join Logs")
        local TextList = Window:AddTextList()
        TextList:EnableSearching()
        TextList:DisplayLogs(Api.LogsRegistry:GetLogs("JoinLogs"), "NewestFirst")
        Window:EnableClosing()
        Window:EnableResizing()
        Window:Show()
    end,
}