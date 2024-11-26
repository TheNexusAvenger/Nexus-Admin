--Implementation of a command.
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))



return {
    Keyword = "chatlogs",
    Category = "BasicCommands",
    Description = "Opens up a window containing the chat logs.",
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        --Create the logs.
        local ChatLogs = Api.Logs.new()
        Api.LogsRegistry:RegisterLogs("ChatLogs", ChatLogs, Api.Configuration:GetCommandAdminLevel("BasicCommands", "chatlogs"))
        local ChatEvents = {}
        
        --[[
        Connects the Chatted event for a player.
        --]]
        local function ConnectPlayerChatted(Player: Player)
            ChatEvents[Player] = Player.Chatted:Connect(function(Message: string)
                ChatLogs:Add(`{Player.Name} [{Api.Time:GetTimeString()}]: {Api.Filter:FilterString(Message, Player)}`)
            end)
        end

        --Connect the players.
        Players.PlayerRemoving:Connect(function(Player)
            if not ChatEvents[Player] then return end
            ChatEvents[Player]:Disconnect()
            ChatEvents[Player] = nil
        end)
        Players.PlayerAdded:Connect(ConnectPlayerChatted)
        for _, Player in Players:GetPlayers() do
            ConnectPlayerChatted(Player)
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()
        
        --Show the window.
        local Window = Api.Window:CreateWindow("Chat Logs")
        local TextList = Window:AddTextList()
        TextList:EnableSearching()
        TextList:DisplayLogs(Api.LogsRegistry:GetLogs("ChatLogs"), "NewestFirst")
        Window:EnableClosing()
        Window:EnableResizing()
        Window:Show()
    end,
}