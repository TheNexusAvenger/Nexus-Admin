--Implementation of a command.
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "loop",
    Category = "BasicCommands",
    Description = "Loops a command for a certain amount of times with a certain interval.",
    Arguments = {
        {
            Type = "integer",
            Name = "Times",
            Description = "Times to run the command.",
        },
        {
            Type = "number",
            Name = "Delay",
            Description = "Delay between rerunning the command.",
        },
        {
            Type = "string",
            Name = "Command",
            Description = "Command to run.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        Api.CommandData.Loops = {}
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Times: number, Delay: number, Command: string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Create the object.
        local Loop = {}
        Loop.Active = false
        function Loop:Start()
            self.Active = true

            for i = 1, Times do
                --Stop if the loop was stopped.
                if not self.Active then
                    break
                end

                --Run the command.
                local Message = Api.Executor:ExecuteCommandWithOrWithoutPrefix(Util:GetRemainingString(CommandContext.RawText, 3), Players.LocalPlayer, CommandContext:GetData())
                if Message ~= "" then
                    Util:SendMessage(Message)
                end

                --Delay for the next run.
                if i ~= Times and Delay > 0 and self.Active then
                    wait(Delay)
                end
            end

            self.Active = false
        end
        function Loop:Stop()
            self.Active = false
        end
        
        --Store the object and run the commands.
        table.insert(Api.CommandData.Loops, Loop)
        Loop:Start()
    end,
}