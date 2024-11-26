--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unadmin",
    Category = "Administrative",
    Description = "Unadmin players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unadmin.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Set the admin levels.
        local ExecutorAdminLevel = Api.Authorization:GetAdminLevel(CommandContext.Executor)
        for _,Player in Players do
            if Player ~= CommandContext.Executor then
                if Api.Authorization:GetAdminLevel(Player) < ExecutorAdminLevel then
                    Api.Authorization:SetAdminLevel(Player,-1)
                else
                    Util:SendError("You can't unadmin players with higher levels than you.")
                end
            else
                Util:SendError("You can't unadmin yourself.")
            end
        end
    end,
}