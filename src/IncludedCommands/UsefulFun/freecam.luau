--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "freecam",
    Category = "UsefulFunCommands",
    Description = "Enables free camera for the calling player. Use Shift + P to toggle.",
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local _ = require(Util.ClientResources:WaitForChild("FreeCamera")) :: any
    end,
}
