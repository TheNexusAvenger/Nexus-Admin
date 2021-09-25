--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local CommonState = require(script.Parent.Parent:WaitForChild("CommonState"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("unban","Administrative","Unbans players.")

    self.Arguments = {
        {
            Type = "string",
            Name = "Players",
            Description = "Players to unban.",
        },
    }
    
    --Connect kciking players on entry.
    self.Players.PlayerAdded:Connect(function(Player)
        local BanData = CommonState.BannedUserIds[Player.UserId]
        if BanData then
            Player:Kick(not BanData and BanData[1])
        end
    end)
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,PlayersString)
    self.super:Run(CommandContext)

    --Get the user ids to remove.
    local UserIdsToRemove = {}
    for _,PlayerString in pairs(string.split(PlayersString,",")) do
        PlayerString = string.lower(PlayerString)
        if PlayerString == "all" or PlayerString == "other" or PlayerString == "*" then
            for UserId,_ in pairs(CommonState.BannedUserIds) do
                table.insert(UserIdsToRemove,UserId)
            end
        else
            for UserId,Data in pairs(CommonState.BannedUserIds) do
                if string.find(Data[2],PlayerString) then
                    table.insert(UserIdsToRemove,UserId)
                else
                    self:SendError("\""..tostring(PlayerString).."\" doesn't match a banned user.")
                end
            end
        end
    end

    --Unban the users.
    for _,UserId in pairs(UserIdsToRemove) do
        CommonState.BannedUserIds[UserId] = nil
    end
end



return Command