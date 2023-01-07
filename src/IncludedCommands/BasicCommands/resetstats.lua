--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "resetstats",
    Category = "BasicCommands",
    Description = "Resets all number leaderstats of a player.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to reset the stats for.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            local leaderstats = Player:FindFirstChild("leaderstats")
            if leaderstats then
                for _,Stat in leaderstats:GetChildren() do
                    if Stat:IsA("ValueBase") and type(Stat.Value) == "number" then
                        (Stat :: NumberValue).Value = 0
                    end
                end
            end
        end
    end,
}