--[[
TheNexusAvenger

Executes commands using Cmdr.
--]]

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))

local Executor = NexusObject:Extend()
Executor:SetClassName("Executor")



--[[
Creates a executor instance.
--]]
function Executor:__new(Cmdr,Registry)
    self:InitializeSuper()
    
    self.Cmdr = Cmdr
    self.Registry = Registry
end

--[[
Executes a command. Authorization checks are performs
in the command if it was registered through Nexus Admin.
--]]
function Executor:ExecuteCommand(Command,ReferencePlayer,Data)
    return self.Cmdr.Dispatcher:EvaluateAndRun(Command,ReferencePlayer,{Data=Data})
end

--[[
Executes a command with prefixes. Authorization checks are performs
in the command if it was registered through Nexus Admin.
--]]
function Executor:ExecuteCommandWithPrefix(Command,ReferencePlayer,Data)
    --Get the command.
    local BaseCommand = Command
    if string.find(Command," ") then
        BaseCommand = string.sub(Command,1,string.find(Command," ") - 1)
    end
    local LowerBaseCommand = string.lower(BaseCommand)

    --Run the command if it exists.
    if self.Registry.PrefixCommands[LowerBaseCommand] then
        return self:ExecuteCommand(string.gsub(Command,BaseCommand,self.Registry.PrefixCommands[LowerBaseCommand]),ReferencePlayer,Data)
    end

    --Return that the command doesn't exist.
    return "Unknown command."
end

--[[
Executes a command that may or may not have a prefix. Authorization
checks are performs in the command if it was registered through
Nexus Admin.
--]]
function Executor:ExecuteCommandWithOrWithoutPrefix(Command,ReferencePlayer,Data)
    local Message = self:ExecuteCommand(Command,ReferencePlayer,Data)
    if Message == "Invalid command. Use the help command to see all available commands." then
        Message = self:ExecuteCommandWithPrefix(Command,ReferencePlayer,Data)
    end

    return Message
end



return Executor