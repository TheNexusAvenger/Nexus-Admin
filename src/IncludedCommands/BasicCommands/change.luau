--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "change",
    Category = "BasicCommands",
    Description = "Changes the stat of a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to reset the stats for.",
        },
        {
            Type = "strings",
            Name = "Stats",
            Description = "Stats to change.",
        },
        {
            Type = "string",
            Name = "Value",
            Description = "Value to change to.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Stats: {string}, Value: string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)

        --Reset the stats.
        for _, Player in Players do
            local leaderstats = Player:FindFirstChild("leaderstats")
            if leaderstats then
                for _, Stat in leaderstats:GetChildren() do
                    for _, StatName in Stats do
                        StatName = string.lower(StatName)
                        if string.sub(string.lower(Stat.Name), 1, string.len(StatName)) == StatName then
                            if type((Stat :: StringValue).Value) == "string" then
                                (Stat :: StringValue).Value = Value
                            elseif type((Stat :: NumberValue).Value) == "number" then
                                (Stat :: NumberValue).Value = tonumber(Value) or (Stat :: NumberValue).Value
                            else
                                Util:SendError("Unable to assign value to stat.")
                            end
                        end
                    end
                end
            end
        end
    end,
}