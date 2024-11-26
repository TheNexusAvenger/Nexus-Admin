--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "kick",
    Category = "Administrative",
    Description = "Kicks players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to kick.",
        },
        {
            Type = "string",
            Name = "Message",
            Description = "Kick message message.",
            Optional = true,
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Message: string?)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        --Kick the players.
        local ExecutorAdminLevel = Api.Authorization:GetAdminLevel(CommandContext.Executor)
        for _, Player in Players do
            if Player ~= CommandContext.Executor then
                if Api.Authorization:GetAdminLevel(Player) < ExecutorAdminLevel then
                    Player:Kick(Message and Api.Filter:FilterString(Message, CommandContext.Executor, Player))
                else
                    Util:SendError("You can't kick admins with higher levels than you.")
                end
            else
                Util:SendError("You can't kick yourself.")
            end
        end
    end,
}