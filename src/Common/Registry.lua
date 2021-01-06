--[[
TheNexusAvenger

Base class for a command registry.
--]]

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))
local ArgumentParser = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("ArgumentParser"))

local Registry = NexusObject:Extend()
Registry:SetClassName("Registry")



--[[
Creates the server registry.
--]]
function Registry:__new(Authorization,Messages)
    self:InitializeSuper()
    
    self.Prefixes = {}
    self.PrefixCommands = {}
    self.CommandsByGroup = {}
    self.Authorization = Authorization
    self.Messages = Messages
    self.RunService = game:GetService("RunService")
end

--[[
Returns a replicatable Cmdr data table from
Nexus Admin command data.
--]]
function Registry:GetReplicatableCmdrData(CommandData)
    local Data = {
        Name = CommandData.Name,
        Group = CommandData.Group or CommandData.Category or CommandData.CommandGroup or "Ungrouped Commands",
        Args = CommandData.Arguments or CommandData.Args or {},
        Description = CommandData.Description or CommandData.ExtraInfo or "No description",
        Aliases = CommandData.Aliases or {},
        AutoExec = CommandData.AutoExec,
    }

    if CommandData.Keyword then
        --Add the name.
        if type(CommandData.Keyword) == "table" then
            Data.Name = CommandData.Keyword[1]
        else
            Data.Name = CommandData.Keyword
        end

        --Add the aliases.
        if type(CommandData.Keyword) == "table" then
            for i = 2,#CommandData.Keyword do
                table.insert(Data.Aliases,CommandData.Keyword[i])
            end
        end
    end

    --Return the data.
    return Data
end

--[[
Performs the BeforeRun verifications
of a CommandContext. Returns a result if
the command can't be run.
--]]
function Registry:PerformBeforeRun(CommandContext)
    --Get the command data.
    if not self.CommandsByGroup[CommandContext.Group] then
        return
    end
    local CommandData
    for _,NewCommandData in pairs(self.CommandsByGroup[CommandContext.Group]) do
        local Names = NewCommandData.Name or NewCommandData.Keyword or ""
        if typeof(NewCommandData.Name or NewCommandData.Keyword) == "string" then
            Names = {Names}
        end
        for _,Name in pairs(Names) do
            if string.lower(Name) == string.lower(CommandContext.Name) then
                CommandData = NewCommandData
                break
            end
        end
    end
    if not CommandData then
        return
    end

    --Return if there is no executor.
    if not CommandContext.Executor and CommandData.AdminLevel then
        return "An executor is required if the admin level is defined."
    end

    --Return if the user is unauthorized.
    if CommandContext.Executor and not self.Authorization:IsPlayerAuthorized(CommandContext.Executor,CommandData.AdminLevel or 1) then
        return "You are not authorized to run this command."
    end
end

--[[
Creates a run method for a given command.
--]]
function Registry:CreateRunMethod(CommandData)
    local CmdrData = self:GetReplicatableCmdrData(CommandData)
    return function(CommandContext,...)
        --Run the command.
        if CommandData.Run then
            return CommandData:Run(CommandContext,...)
        elseif CommandData.OnCommandInvoked then
            warn("Command.OnCommandInvoked(Player,BaseMessage,Arguments/ArgumentParser) (used in "..(CmdrData.Name or "")..") is deprecated as of V.2.0.0. Command:Run(CommandContext) should be used instead.")
            
            --Get the arguments string.
            local ArgumentsString = ""
            if string.find(CommandContext.RawText," ") then
                ArgumentsString = string.sub(CommandContext.RawText,string.find(CommandContext.RawText," ") + 1)
            end

            --Call the function.
            if CommandData.Arguments then
                warn("Command.OnCommandInvoked with Arguments (used in "..(CmdrData.Name or "")..") is deprecated as of V.1.1.0. Command:Run(CommandContext) should be used instead.")
                return CommandData.OnCommandInvoked(CommandContext.Executor,CommandContext.RawText,unpack(ArgumentParser:StringToArguments(ArgumentsString,CommandData.Arguments,CommandContext.Executor,CommandData.IgnoreFilter)))
            else
                return CommandData.OnCommandInvoked(CommandContext.Executor,CommandContext.RawText,ArgumentParser:CreateParser(ArgumentsString,CommandContext.Executor))
            end
        end
    end
end

--[[
Loads a command.
--]]
function Registry:LoadCommand(CommandData)
    local Data = self:GetReplicatableCmdrData(CommandData)

    --Add the prefix commands.
    if CommandData.Prefix then
        --Get the prefixes.
        local Prefixes = CommandData.Prefix
        if type(Prefixes) == "string" then
            Prefixes = {Prefixes}
        end

        --Add the prefixes.
        for _,Prefix in pairs(Prefixes) do
            self.Prefixes[string.lower(Prefix)] = true
            self.PrefixCommands[string.lower(Prefix..Data.Name)] = string.lower(Data.Name)
            for _,Alias in pairs(Data.Aliases) do
                self.PrefixCommands[string.lower(Prefix..Alias)] = string.lower(Alias)
            end
        end
    end

    --Add the command data.
    if not self.CommandsByGroup[Data.Group] then
        self.CommandsByGroup[Data.Group] = {}
    end
    table.insert(self.CommandsByGroup[Data.Group],CommandData)
end



return Registry