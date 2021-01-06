--[[
TheNexusAvenger

Extension of the base command for commands
native to Cmdr and can only run in the command line.
--]]

local BaseCommand = require(script.Parent:WaitForChild("BaseCommand"))

local CmdrCommand = BaseCommand:Extend()
CmdrCommand:SetClassName("CmdrCommand")



--[[
Creates the command.
--]]
function CmdrCommand:__new()
    self:InitializeSuper()
    
    self.Prefix = nil
    self.Arguments = nil
    self.AdminLevel = -1
end

--[[
Runs the Cmdr command.
--]]
function CmdrCommand:RunCommand(Context,...)

end

--[[
Runs the command.
--]]
function CmdrCommand:Run(CommandContext,...)
    BaseCommand.Run(self,CommandContext) --Calling super references itself in most cases.

    --Return if it wasn't executed from the command line.
    if self:ExecutedFromChat() or self:ExecutedFromGuiConsole() or self:ExecutedFromGuiConsole() then
        return "This command is only intended to be run from the Cmdr command line."
    end

    --Run the command.
    return self.object:RunCommand(CommandContext,...)
end


return CmdrCommand