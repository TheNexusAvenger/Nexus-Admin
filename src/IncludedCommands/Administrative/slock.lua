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
    Description = "Locks and unlocks the server for non-admins.",
    Arguments = {
        {
            Type = "boolean",
            Name = "Active",
            Description = "Whether the server lock is active or not.",
            Optional = true,
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        Api.CommandData.ServerLocked = false
        Players.PlayerAdded:Connect(function(Player)
            if Api.CommandData.ServerLocked and Api.Authorization:YieldForAdminLevel(Player) < 0 then
                Player:Kick("Server was locked by an admin. Please try again later.")
                for _, Admin in Players:GetPlayers() do
                    if Api.Authorization:GetAdminLevel(Admin) >= 0 then
                        Api.Messages:DisplayHint(Admin, Player.Name.." ("..Player.DisplayName..", "..tostring(Player.UserId)..") tried to enter the server.")
                    end
                end
            end
        end)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Active: boolean?)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Set the server lock.
        if Active ~= nil then
            Api.CommandData.ServerLocked = Active
        else
            Api.CommandData.ServerLocked = not Api.CommandData.ServerLocked
        end

        --Display a message.
        if Api.CommandData.ServerLocked then
            return "Server has been locked."
        else
            return "Server has been unlocked."
        end
    end,
}