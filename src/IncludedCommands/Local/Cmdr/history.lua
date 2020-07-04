--[[
TheNexusAvenger

Implementation of a Cmdr command.
--]]

local CmdrCommand = require(script.Parent.Parent:WaitForChild("CmdrCommand"))
local Command = CmdrCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper()

    self.Name = "history"
    self.Aliases = {}
    self.AutoExec = {
        "alias ! run ${history $1}";
        "alias ^ run ${run replace ${history -1} $1 $2}";
        "alias !! ! -1";
    }
    self.Description = "Displays previous commands from history.";
    self.Group = "DefaultUtil"
    self.Args = {
        {
            Type = "integer";
            Name = "Line Number";
            Description = "Command line number (can be negative to go from end)"
        },
    }
end

--[[
Runs the Cmdr command.
--]]
function Command:RunCommand(context, line)
    local history = context.Dispatcher:GetHistory()

    if line <= 0 then
        line = #history + line
    end

    return history[line] or ""
end



return Command