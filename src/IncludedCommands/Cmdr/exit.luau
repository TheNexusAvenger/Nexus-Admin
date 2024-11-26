--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "exit",
    Category = "DefaultUtil",
    Description = "Closes the command line. (Added by Nexus Admin.)",
    AllowAllUsers = true,
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)

        --Return if it wasn't executed from the command line.
        if Util:ExecutedFromChat() or Util:ExecutedFromGuiConsole() or Util:ExecutedFromKeybind() then
            return "This command is only intended to be run from the Cmdr command line."
        end

        --Toggle the window.
        (IncludedCommandUtil.ForContext(CommandContext):GetApi().Cmdr :: any):Toggle()
        return ""
    end,
}