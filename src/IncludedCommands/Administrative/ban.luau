--Implementation of a command.
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "ban",
    Category = "Administrative",
    Description = "Bans players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to ban.",
        },
        {
            Type = "string",
            Name = "Message",
            Description = "Ban message.",
            Optional = true,
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        --Connect kicking players on entry.
        Players.PlayerAdded:Connect(function(Player: Player)
            local BanData = Api.CommandData.BannedUserIds[Player.UserId]
            if BanData then
                if BanData[1] == true then
                    Player:Kick()
                else
                    Player:Kick(BanData[1])
                end
            end
        end)

        --Add the configuration bans.
        Api.CommandData.BannedUserIds = {}
        for UserId, Reason in Api.Configuration.BannedUsers do
            Api.CommandData.BannedUserIds[UserId] = {Reason, "NAME NOT FETCHED", "NAME NOT FETCHED"}
            task.spawn(function()
                pcall(function()
                    local Name = Players:GetNameFromUserIdAsync(UserId)
                    Api.CommandData.BannedUserIds[UserId][2] = string.lower(Name)
                    Api.CommandData.BannedUserIds[UserId][3] = Name
                end)
            end)
        end
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Message: string?)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        --Ban the players.
        local ExecutorAdminLevel = Api.Authorization:GetAdminLevel(CommandContext.Executor)
        for _, Player in Players do
            if Player ~= CommandContext.Executor then
                if Api.Authorization:GetAdminLevel(Player) < ExecutorAdminLevel then
                    local FilteredMessage = Message and Api.Filter:FilterString(Message, CommandContext.Executor, Player)
                    Api.CommandData.BannedUserIds[Player.UserId] = {FilteredMessage or true, string.lower(Player.Name), Player.Name}
                    Player:Kick(FilteredMessage)
                else
                    Util:SendError("You can't ban admins with higher levels than you.")
                end
            else
                Util:SendError("You can't ban yourself.")
            end
        end
    end,
}