--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "exit",
    Category = "DefaultUtil",
    Description = "Closes the command line. (Added by Nexus Admin.)",
    AllowAllUsers = true,
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        (IncludedCommandUtil.ForContext(CommandContext):GetApi().Cmdr :: any):Toggle()
        return ""
    end,
}