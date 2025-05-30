--Implementation of a command.
--!strict

local TextChatService = game:GetService("TextChatService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "mute",
    Category = "BasicCommands",
    Description = "Mutes a set of players. Admins can not be muted.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to mute.",
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        --Create the event.
        Api.CommandData.MutedPlayers = {}

        --Handle muted players joining.
        task.spawn(function()
            local TextChannels = TextChatService:WaitForChild("TextChannels", 10 ^ 99)
            local GeneralChat = TextChannels:WaitForChild("RBXGeneral")
            GeneralChat.ChildAdded:Connect(function(TextSource)
                if not TextSource:IsA("TextSource") then return end
                if not Api.CommandData.MutedPlayers[TextSource.UserId] then return end
                TextSource.CanSend = false
            end)
        end)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Mute the players.
        local TextChannels = TextChatService:FindFirstChild("TextChannels")
        local GeneralChat = TextChannels and TextChannels:FindFirstChild("RBXGeneral")
        for _, Player in Players do
            if Api.Authorization:GetAdminLevel(Player) >= 0 then
                Util:SendError("You can't mute admins.")
            else
                Api.CommandData.MutedPlayers[Player.UserId] = true
                local PlayerSource = GeneralChat and GeneralChat:FindFirstChild(Player.Name) :: TextSource
                if PlayerSource then
                    PlayerSource.CanSend = false
                end
            end
        end
    end,
}