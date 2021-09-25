--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local CommonState = require(script.Parent.Parent:WaitForChild("CommonState"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("loop","BasicCommands","Loops a command for a certain amount of times with a certain interval.")

    self.Arguments = {
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
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Times,Delay,Command)
    self.super:Run(CommandContext)

    --Create the psuedo-object.
    local Loop = {}
    Loop.Active = false
    function Loop.Start(Loop)
        Loop.Active = true

        for i = 1,Times do
            --Stop if the loop was stopped.
            if not Loop.Active then
                break
            end

            --Run the command.
            local Message = self.API.Executor:ExecuteCommandWithOrWithoutPrefix(self:GetRemainingString(CommandContext.RawText,3),self.Players.LocalPlayer,CommandContext:GetData())
            if Message ~= "" then
                self:SendMessage(Message)
            end

            --Delay for the next run.
            if i ~= Times and Delay > 0 and Loop.Active then
                wait(Delay)
            end
        end

        Loop.Active = false
    end
    function Loop:Stop()
        self.Active = false
    end
    
    --Store the object and run the commands.
    table.insert(CommonState.Loops,Loop)
    Loop:Start()
end



return Command