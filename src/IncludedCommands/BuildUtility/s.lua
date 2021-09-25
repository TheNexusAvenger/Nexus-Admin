--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()
Command.loadstring = loadstring



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("s","BuildUtility","Executes a string as a script. ServerScriptService.LoadStringEnabled must be enabled.")
    self.LoadStringEnabled = pcall(function() self.loadstring("local Works = true")() end)

    self.Arguments = {
        {
            Type = "string",
            Name = "Source",
            Description = "Source to run.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Source)
    self.super:Run(CommandContext)
    
    --Run the source.
    if not self.LoadStringEnabled then
        return "LoadStringEnabled is not enabled. Scripts can't be run."
    else
        self.loadstring(Source)()
    end
end



return Command