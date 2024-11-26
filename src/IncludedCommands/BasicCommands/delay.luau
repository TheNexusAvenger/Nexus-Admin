--Implementation of a command.
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "delay",
    Category = "BasicCommands",
    Description = "Runs a command after a given amount of seconds.",
    Arguments = {
        {
            Type = "number",
            Name = "Delay",
            Description = "Delay before running the command.",
        },
        {
            Type = "string",
            Name = "Command",
            Description = "Command to run.",
        },
    },
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Delay: number)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Schedule the command.
        task.delay(Delay, function()
            local Message = Api.Executor:ExecuteCommandWithOrWithoutPrefix(Util:GetRemainingString(CommandContext.RawText,2), Players.LocalPlayer, CommandContext:GetData())
            if Message ~= "" then
                Util:SendMessage(Message)
            end
        end)

        --Return the command being scheduled.
        if Delay == 1 then
            return "Command scheduled to run in 1 second."
        else
            return `Command scheduled to run in {Delay} seconds.`
        end
    end,
}