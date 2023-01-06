--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "admin",
    Category = "Administrative",
    Description = "Sets the admin level of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to change the admin level of.",
        },
        {
            Type = "number",
            Name = "Value",
            Description = "Admin level to use.",
            Optional = true,
            Default = 1,
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, AdminLevel: number): string?
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Return if the admin level is higher than the player's admin level.
        local ExecutorAdminLevel = Api.Authorization:GetAdminLevel(CommandContext.Executor)
        if AdminLevel >= ExecutorAdminLevel then
            return "You can't set admin levels higher than yours."
        end

        --Set the admin levels.
        for _,Player in pairs(Players) do
            if Player ~= CommandContext.Executor then
                if Api.Authorization:GetAdminLevel(Player) < ExecutorAdminLevel then
                    Api.Authorization:SetAdminLevel(Player,AdminLevel)
                else
                    Util:SendError("You can't change admins with higher levels than you.")
                end
            else
                Util:SendError("You can't change your own admin level.")
            end
        end
        return nil
    end,
}