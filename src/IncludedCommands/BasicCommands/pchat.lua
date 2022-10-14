--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper({"pchat", "pc"}, "BasicCommands", "Starts a private chat between a set of players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to run the vote for.",
        },
        {
            Type = "string",
            Name = "Question",
            Description = "Message to send.",
        },
    }

    --Set up the remote objects.
    local SendPrivateMessageRemoteEvent = Instance.new("RemoteEvent")
    SendPrivateMessageRemoteEvent.Name = "SendPrivateMessage"
    SendPrivateMessageRemoteEvent.Parent = self.API.EventContainer
    self.SendPrivateMessageRemoteEvent = SendPrivateMessageRemoteEvent

    local ClosePrivateMessageRemoteEvent = Instance.new("RemoteEvent")
    ClosePrivateMessageRemoteEvent.Name = "ClosePrivateMessage"
    ClosePrivateMessageRemoteEvent.Parent = self.API.EventContainer

    self.SenderCounts = {}
    SendPrivateMessageRemoteEvent.OnServerEvent:Connect(function(Player, TargetPlayer, Message)
        self:SendMessage(Player, TargetPlayer, Message)
    end)

    ClosePrivateMessageRemoteEvent.OnServerEvent:Connect(function(Player, TargetPlayer)
        self:RemoveSenderCount(Player, TargetPlayer)
    end)

    --Connect clearing the counts for players that leave.
    self.Players.PlayerRemoving:Connect(function(Player)
        self.SenderCounts[Player] = nil
        for _, PlayerSenderCounts in self.SenderCounts do
            PlayerSenderCounts[Player] = nil
        end
    end)
end

--[[
Adds a count for allowing a player to send a message to another.
--]]
function Command:AddSenderCount(SenderPlayer, TargetPlayer)
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
function Command:RemoveSenderCount(SenderPlayer, TargetPlayer)
    if not self.SenderCounts[SenderPlayer] then
        warn(tostring(SenderPlayer).." tried to send a message to "..tostring(TargetPlayer).." but has never been authorized to send messages.")
        return false
    end
    if not self.SenderCounts[SenderPlayer][TargetPlayer] or self.SenderCounts[SenderPlayer][TargetPlayer] <= 0 then
        warn(tostring(SenderPlayer).." tried to send a message to "..tostring(TargetPlayer).." but is not authorized to send a new message.")
        return false
    end

    self.SenderCounts[SenderPlayer][TargetPlayer] += -1
    return true
end

--[[
Sends a message from 1 player to another.
--]]
function Command:SendMessage(SenderPlayer, TargetPlayer, Message)
    --Return if there is no sender key for the player.
    if not self:RemoveSenderCount(SenderPlayer, TargetPlayer) then
        return
    end

    --Send the message.
    Message = self.API.Filter:FilterString(Message, SenderPlayer, TargetPlayer)
    self:AddSenderCount(TargetPlayer, SenderPlayer)
    self.SendPrivateMessageRemoteEvent:FireClient(TargetPlayer, SenderPlayer, Message)
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext, Players, Message)
    self.super:Run(CommandContext)

    --Invoke the server to send messages.
    for _, Player in pairs(Players) do
        self:AddSenderCount(CommandContext.Executor, Player)
        self:SendMessage(CommandContext.Executor, Player, Message)
    end
end



return Command