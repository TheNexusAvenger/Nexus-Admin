--Implementation of a command.
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "batch",
    Category = "BasicCommands",
    Description = "Performs several commands at once.",
    Arguments = {
        {
            Type = "string",
            Name = "Command/Command/Command...",
            Description = "Commands to run.",
        },
    },
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Run the commands.
        for _, Command in Api.Executor:SplitCommands(Util:GetRemainingString(CommandContext.RawText, 1), "/") do
            local Message = Api.Executor:ExecuteCommandWithOrWithoutPrefix(Command, Players.LocalPlayer, CommandContext:GetData())
            if Message ~= "" then
                Util:SendMessage(Message)
            end
        end
    end,
}