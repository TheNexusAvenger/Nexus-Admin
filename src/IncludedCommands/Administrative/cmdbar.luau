--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "cmdbar",
    Category = "Administrative",
    Description = "Brings up the command line. Alternative to pressing F2.",
    Prefix = "!",
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        (IncludedCommandUtil.ForContext(CommandContext):GetApi().Cmdr :: any):SetEnabled(true)
    end,
}