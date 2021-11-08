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
Unescapes a command.
--]]
function Executor:Unescape(Command)
    --Trim the whitespace.
    Command = string.match(Command,"^%s*(.*)")
    Command = string.match(Command,"(.-)%s*$")

    --Build the new command based on the escaping.
    local NewCommand = ""
    local Escaping = false
    for i = 1,string.len(Command) do
        --Process the character.
        local Character = string.sub(Command,i,i)
        if Character == "\\" then
            if Escaping then
                NewCommand = NewCommand.."\\"
            end
            Escaping = not Escaping
        elseif Character == "\"" then
            if Escaping then
                NewCommand = NewCommand.."\""
            end
            Escaping = false
        else
            NewCommand = NewCommand..Character
            Escaping = false
        end
    end

    --Return the new command.
    return NewCommand
end

--[[
Executes a command. Authorization checks are performs
in the command if it was registered through Nexus Admin.
--]]
function Executor:ExecuteCommand(Command,ReferencePlayer,Data)
    return self.Cmdr.Dispatcher:EvaluateAndRun(self:Unescape(Command),ReferencePlayer,{Data=Data})
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
    if string.find(Message,"Use the help command to see all available commands.") then
        Message = self:ExecuteCommandWithPrefix(Command,ReferencePlayer,Data)
    end

    return Message
end

--[[
Splits a set of commands by a separator for use with other commands,
like with the batch command.
--]]
function Executor:SplitCommands(Command,Separator)
    --Get the indvidual commands.
    local Commands = {}
    local InQuotes = false
    local Escaping = false
    local CurrentCommand = ""
    for i = 1,string.len(Command) do
        --Process the character.
        local Character = string.sub(Command,i,i)
        if Character == "\\" then
            CurrentCommand = CurrentCommand..Character
            Escaping = not Escaping
        elseif Character == "\"" then
            if not Escaping then
                InQuotes = not InQuotes
            end
            CurrentCommand = CurrentCommand..Character
            Escaping = false
        elseif Character == Separator then
            if not InQuotes then
                table.insert(Commands,CurrentCommand)
                CurrentCommand = ""
            else
                CurrentCommand = CurrentCommand..Character
            end
            Escaping = false
        else
            CurrentCommand = CurrentCommand..Character
            Escaping = false
        end
    end
    table.insert(Commands,CurrentCommand)

    --Un-escape the commands.
    for i = 1,#Commands do
        Commands[i] = self:Unescape(Commands[i])
    end

    --Return the sections.
    return Commands
end



return Executor