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
        Api.CommandData.MinimumAdminLevel = nil

        --Connect kicking players that enter with an active server lock.
        Players.PlayerAdded:Connect(function(Player)
            if not Api.CommandData.MinimumAdminLevel then
                return
            end
            local PlayerLevel = Api.Authorization:YieldForAdminLevel(Player)
            if PlayerLevel < Api.CommandData.MinimumAdminLevel then
                Player:Kick("Server was locked by an admin. Please try again later.")
                for _, Admin in Players:GetPlayers() do
                    if Api.Authorization:GetAdminLevel(Admin) >= Api.CommandData.MinimumAdminLevel then
                        Api.Messages:DisplayHint(Admin, Player.Name.." ("..Player.DisplayName..", "..tostring(Player.UserId)..") tried to enter the server. ("..tostring(PlayerLevel).." < "..tostring(Api.CommandData.MinimumAdminLevel)..")")
                    end
                end
            end
        end)

        --Connect disabling the server lock if the no one in the game is high enough.
        Players.PlayerRemoving:Connect(function()
            if not Api.CommandData.MinimumAdminLevel then
                return
            end

            --Set HighestAdminLevel to an unreasonably low number to avoid error.
            local HighestAdminLevel = -math.huge
            for _, Player in Players:GetPlayers() do
                local AdminLevel = Api.Authorization:YieldForAdminLevel(Player)
                if AdminLevel > HighestAdminLevel then
                    HighestAdminLevel = AdminLevel
                end
            end

            --If there is no player with a higher AdminLevel than the current server lock admin level disable server lock.
            if HighestAdminLevel < Api.CommandData.MinimumAdminLevel then
                Api.CommandData.MinimumAdminLevel = nil
            end
        end)

        --Warn if the default admin level is above the command's admin level.
        if Api.Configuration.CommandConfigurations.DefaultServerLockAdminLevel > Api.Configuration:GetCommandAdminLevel("Administrative", "slock") then
            warn("CommandConfigurations.DefaultServerLockAdminLevel in the Nexus Admin configuration is set above the admin level of slock. Some admins will not be able to use slock without specifying a minimum admin level.")
        end
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Active: boolean?, AdminLevel: number?)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        
        --Define the DefaultServerLockAdminLevel to avoid repetitive calls.
        local DefaultServerLockAdminLevel = Api.Configuration.CommandConfigurations.DefaultServerLockAdminLevel
        if Api.CommandData.MinimumAdminLevel and Api.Authorization:YieldForAdminLevel(CommandContext.Executor) < Api.CommandData.MinimumAdminLevel then
            return "Cannot change server lock above your own admin level."
        end

        --Determine if the server lock should be enable or disabled.
        if Active == nil then
            Active = (Api.CommandData.MinimumAdminLevel == nil)
        end

        --Set the server lock.
        if Active then
            --Set the server lock AdminLevel.
            local NewAdminLevel = AdminLevel or DefaultServerLockAdminLevel
            if Api.Authorization:YieldForAdminLevel(CommandContext.Executor) < NewAdminLevel then
                return "Cannot set server lock above your own admin level. ("..tostring(Api.Authorization:GetAdminLevel(CommandContext.Executor)).." < "..tostring(NewAdminLevel)..")"
            end
            Api.CommandData.MinimumAdminLevel = NewAdminLevel
        else
            --Disable the server lock.
            Api.CommandData.MinimumAdminLevel = nil
        end

        --Display a message.
        if Api.CommandData.MinimumAdminLevel then
            return "Server has been locked to admin level "..tostring(Api.CommandData.MinimumAdminLevel).."."
        else
            return "Server has been unlocked."
        end
    end,
}
