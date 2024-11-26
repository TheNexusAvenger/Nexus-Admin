--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "removeteam",
    Category = "BasicCommands",
    Description = "Removes selected teams.",
    Arguments = {
        {
            Type = "teams",
            Name = "Teams",
            Description = "Teams to remove.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Teams: {Team})
        for _,Team in Teams do
            Team:Destroy()
        end
    end,
}