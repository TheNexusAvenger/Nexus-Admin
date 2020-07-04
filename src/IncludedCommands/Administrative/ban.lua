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
    self:InitializeSuper("ban","Administrative","Bans players.")

    self.Arguments = {
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
    }
    
    --Connect kicking players on entry.
    self.Players.PlayerAdded:Connect(function(Player)
        local BanData = CommonState.BannedUserIds[Player.UserId]
        if BanData then
            if BanData[1] == true then
                Player:Kick()
            else
                Player:Kick(BanData[1])
            end
        end
    end)

    --Add the configuration bans.
    for UserId,Reason in pairs(self.API.Configuration.BannedUsers) do
        CommonState.BannedUserIds[UserId] = {Reason,"NAME NOT FETCHED","NAME NOT FETCHED"}
        coroutine.wrap(function()
            pcall(function()
                local Name = self.Players:GetNameFromUserIdAsync(UserId)
                CommonState.BannedUserIds[UserId][2] = string.lower(Name)
                CommonState.BannedUserIds[UserId][3] = Name
            end)
        end)()
    end
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Message)
    self.super:Run(CommandContext)

    --Ban the players.
    local ExecutorAdminLevel = self.API.Authorization:GetAdminLevel(CommandContext.Executor)
    for _,Player in pairs(Players) do
        if Player ~= CommandContext.Executor then
            if self.API.Authorization:GetAdminLevel(Player) < ExecutorAdminLevel then
                CommonState.BannedUserIds[Player.UserId] = {Message or true,string.lower(Player.Name),Player.Name}
                Player:Kick(Message)
            else
                self:SendError("You can't ban admins with higher levels than you.")
            end
        else
            self:SendError("You can't ban yourself.")
        end
    end
end



return Command