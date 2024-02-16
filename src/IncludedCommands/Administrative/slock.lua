--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"slock", "serverlock"},
    Category = "Administrative",
    Description = "Locks and unlocks the server for non-admins or a minimum AdminLevel.",
    Arguments = {
        {
            Type = "boolean",
            Name = "Active",
            Description = "Whether the server lock is active or not.",
            Optional = true,
        },
        {
            Type = "number",
            Name = "AdminLevel",
            Description = "Minimum AdminLevel a player must have to join.",
            Optional = true,
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        Api.CommandData.ServerLock = {
            Locked = false,
            AdminLevel = 0,    
        }
        Players.PlayerAdded:Connect(function(Player)
            if Api.CommandData.ServerLock.Locked and Api.Authorization:YieldForAdminLevel(Player) < Api.CommandData.ServerLock.AdminLevel then
                Player:Kick("Server was locked by an admin. Please try again later.")
                for _, Admin in Players:GetPlayers() do
                    if Api.Authorization:GetAdminLevel(Admin) >= Api.CommandData.ServerLock.AdminLevel then
                        Api.Messages:DisplayHint(Admin, Player.Name.." ("..Player.DisplayName..", "..tostring(Player.UserId)..") tried to enter the server.")
                    end
                end
            end
        end)
        Players.PlayerRemoving:Connect(function()
            -- Set HighestAdminLevel to an unreasonably low number to avoid error
            local HighestAdminLevel = -math.huge
            for _, Player in Players:GetPlayers() do
                local AdminLevel = Api.Authorization:YieldForAdminLevel(Player)
                if AdminLevel > HighestAdminLevel then
                    HighestAdminLevel = AdminLevel
                end
            end
            
            -- If there is no player with a higher AdminLevel than the current ServerLock AdminLevel disable ServerLock
            if HighestAdminLevel < Api.CommandData.ServerLock.AdminLevel then
                Api.CommandData.ServerLock = {
                    Locked = false,
                    AdminLevel = 0,    
                }
            end
        end)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Active: boolean?, AdminLevel: number?)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        
        print(Api.CommandData.ServerLock)
        
        if Api.Authorization:YieldForAdminLevel(CommandContext.Executor) < Api.CommandData.ServerLock.AdminLevel then
            return "Cannot change ServerLock above your own AdminLevel."
        end

        --Set the server lock.
        if Active ~= nil then
            Api.CommandData.ServerLock.Locked = Active

            --Set the server lock AdminLevel
            if AdminLevel ~= nil then
                if Api.Authorization:YieldForAdminLevel(CommandContext.Executor) < AdminLevel then
                    return "Cannot set ServerLock above your own AdminLevel."
                end
                Api.CommandData.ServerLock.AdminLevel = AdminLevel
            end
        else
            if Api.Authorization:YieldForAdminLevel(CommandContext.Executor) < Api.Configuration.DefaultAdminLevel + 1 then
                return "Cannot set ServerLock above your own AdminLevel."
            end
            Api.CommandData.ServerLock.Locked = not Api.CommandData.ServerLock.Locked
            Api.CommandData.ServerLock.AdminLevel = Api.Configuration.DefaultAdminLevel + 1
        end

        --Display a message.
        if Api.CommandData.ServerLock.Locked then
            return "Server has been locked to AdminLevel "..tostring(Api.CommandData.ServerLock.AdminLevel).."."
        else
            return "Server has been unlocked."
        end
    end,
}
