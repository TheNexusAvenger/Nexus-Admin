--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unkeybind",
    Category = "Administrative",
    Description = "Unbinds the key from all commands.",
    Prefix = "!",
    Arguments = {
        {
            Type = "userInput",
            Name = "Key",
            Description = "Key to bind.",
        },
    },
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Key: Enum.KeyCode)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Unbind the key.
        if Api.CommandData.Keybinds[Key] then
            Api.CommandData.Keybinds[Key] = nil
            return "Key unbound."
        else
            return "Key was not bound."
        end
    end,
}