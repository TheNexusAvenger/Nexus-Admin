--[[
TheNexusAvenger

Implementation of a command.
--]]

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
            JoinLogs:Add("["..Api.Time:GetTimeString().."]: "..Player.DisplayName.." ("..Player.Name..", "..tostring(Player.UserId)..") joined.")
        end)
        Players.PlayerRemoving:Connect(function(Player)
            JoinLogs:Add("["..Api.Time:GetTimeString().."]: "..Player.DisplayName.." ("..Player.Name..", "..tostring(Player.UserId)..") left.")
        end)
        for _, Player in Players:GetPlayers() do
            JoinLogs:Add("["..Api.Time:GetTimeString().."]: "..Player.DisplayName.." ("..Player.Name..", "..tostring(Player.UserId)..") was already in the server when Nexus Admin loaded.")
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local Window = ScrollingTextWindow.new()
        Window.Title = "Join Logs"
        Window:DisplayLogs(Api.LogsRegistry:GetLogs("JoinLogs"))
        Window:Show()
    end,
}