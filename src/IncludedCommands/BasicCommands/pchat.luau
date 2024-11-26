--Implementation of a command.
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"pchat", "pc"},
    Category = "BasicCommands",
    Description = "Starts a private chat between a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to run the vote for.",
        },
        {
            Type = "string",
            Name = "Message",
            Description = "Message to send.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApi)
        local PrivateChatWindow = require(IncludedCommandUtil.ClientResources:WaitForChild("PrivateChatWindow")) :: any
        (Api.EventContainer:WaitForChild("SendPrivateMessage") :: RemoteEvent).OnClientEvent:Connect(function(Player: Player, Message: string)
            local Window = PrivateChatWindow.new(Player, Message)
            function Window.OnMessage(_, Message: string)
                (Api.EventContainer:WaitForChild("SendPrivateMessage") :: RemoteEvent):FireServer(Player, Message)
                Window:OnClose()
            end
            Window.CloseButton.MouseButton1Down:Connect(function()
                (Api.EventContainer:WaitForChild("ClosePrivateMessage") :: RemoteEvent):FireServer(Player)
            end)
            Window:Show()
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local SendPrivateMessageRemoteEvent = IncludedCommandUtil:CreateRemote("RemoteEvent", "SendPrivateMessage")
        local ClosePrivateMessageRemoteEvent = IncludedCommandUtil:CreateRemote("RemoteEvent", "ClosePrivateMessage")
        local PrivateMessages = {
            SenderCounts = {},
        }
        Api.CommandData.PrivateMessages = PrivateMessages

        --[[
        Adds a count for allowing a player to send a message to another.
        --]]
        function PrivateMessages:AddSenderCount(SenderPlayer: Player, TargetPlayer: Player): ()
            if not self.SenderCounts[SenderPlayer] then
                self.SenderCounts[SenderPlayer] = {}
            end
            if not self.SenderCounts[SenderPlayer][TargetPlayer] then
                self.SenderCounts[SenderPlayer][TargetPlayer] = 0
            end
            self.SenderCounts[SenderPlayer][TargetPlayer] += 1
        end

        --[[
        Removes a count for allowing a player to send a message to another.
        Returns if a key was removed.
        --]]
        function PrivateMessages:RemoveSenderCount(SenderPlayer: Player, TargetPlayer: Player): boolean
            if not self.SenderCounts[SenderPlayer] then
                warn(`{SenderPlayer} tried to send a message to {TargetPlayer} but has never been authorized to send messages.`)
                return false
            end
            if not self.SenderCounts[SenderPlayer][TargetPlayer] or self.SenderCounts[SenderPlayer][TargetPlayer] <= 0 then
                warn(`{SenderPlayer} tried to send a message to {TargetPlayer} but is not authorized to send a new message.`)
                return false
            end

            self.SenderCounts[SenderPlayer][TargetPlayer] += -1
            return true
        end

        --[[
        Sends a message from 1 player to another.
        --]]
        function PrivateMessages:SendMessage(SenderPlayer: Player, TargetPlayer: Player, Message: string): ()
            --Return if there is no sender key for the player.
            if not self:RemoveSenderCount(SenderPlayer, TargetPlayer) then
                return
            end

            --Send the message.
            Message = Api.Filter:FilterString(Message, SenderPlayer, TargetPlayer)
            self:AddSenderCount(TargetPlayer, SenderPlayer)
            SendPrivateMessageRemoteEvent:FireClient(TargetPlayer, SenderPlayer, Message)
        end

        --Set up the remote objects.
        SendPrivateMessageRemoteEvent.OnServerEvent:Connect(function(Player: Player, TargetPlayer: Player, Message: string)
            PrivateMessages:SendMessage(Player, TargetPlayer, Message)
        end)

        ClosePrivateMessageRemoteEvent.OnServerEvent:Connect(function(Player: Player, TargetPlayer: Player)
            PrivateMessages:RemoveSenderCount(Player, TargetPlayer)
        end)

        --Connect clearing the counts for players that leave.
        Players.PlayerRemoving:Connect(function(Player)
            PrivateMessages.SenderCounts[Player] = nil
            for _, PlayerSenderCounts in PrivateMessages.SenderCounts do
                PlayerSenderCounts[Player] = nil
            end
        end)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Message: string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Invoke the server to send messages.
        local PrivateMessages = Api.CommandData.PrivateMessages
        for _, Player in Players do
            PrivateMessages:AddSenderCount(CommandContext.Executor, Player)
            PrivateMessages:SendMessage(CommandContext.Executor, Player, Message)
        end
    end
}