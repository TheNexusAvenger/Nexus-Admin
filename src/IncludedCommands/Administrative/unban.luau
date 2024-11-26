--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unban",
    Category = "Administrative",
    Description = "Unbans players.",
    Arguments = {
        {
            Type = "string",
            Name = "Players",
            Description = "Players to unban.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, PlayersString: string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Get the user ids to remove.
        local UserIdsToRemove = {}
        for _, PlayerString in string.split(PlayersString, ",") do
            PlayerString = string.lower(PlayerString)
            if PlayerString == "all" or PlayerString == "other" or PlayerString == "*" then
                for UserId, _ in Api.CommandData.BannedUserIds do
                    table.insert(UserIdsToRemove, UserId)
                end
            else
                for UserId, Data in Api.CommandData.BannedUserIds do
                    if string.find(Data[2], PlayerString) then
                        table.insert(UserIdsToRemove, UserId)
                    else
                        Util:SendError(`"{PlayerString}" doesn't match a banned user.`)
                    end
                end
            end
        end

        --Unban the users.
        for _, UserId in UserIdsToRemove do
            Api.CommandData.BannedUserIds[UserId] = nil
        end
    end,
}