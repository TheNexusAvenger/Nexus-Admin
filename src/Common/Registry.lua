--[[
TheNexusAvenger

Base class for a command registry.
--]]
--!strict

local ArgumentParser = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("ArgumentParser"))
local Types = require(script.Parent.Parent:WaitForChild("Types"))

local Registry = {}
Registry.__index = Registry



--[[
Creates the server registry.
--]]
function Registry.new(Authorization: Types.Authorization, Messages: Types.MessagesServer | Types.MessagesClient, Cmdr: Types.Cmdr, NexusAdminRemotes: Folder): Types.Registry
    local self = {}
    self.Prefixes = {}
    self.PrefixCommands = {}
    self.CommandsByGroup = {}
    self.Authorization = Authorization
    self.Messages = Messages
    self.Cmdr = Cmdr
    self.RunService = game:GetService("RunService")
    self.HttpService = game:GetService("HttpService")
    setmetatable(self, Registry)

    --Set up storing enum types.
    if self.RunService:IsServer() then
        self.EnumTypesFolder = Instance.new("Folder")
        self.EnumTypesFolder.Name = "EnumTypes"
        self.EnumTypesFolder.Parent = NexusAdminRemotes
    else
        self.EnumTypesFolder = (NexusAdminRemotes:WaitForChild("EnumTypes") :: Folder)
    end

    --Set up registering enum types.
    self.EnumTypesFolder.ChildAdded:Connect(function(ChildValue)
        self:SetUpEnumValue(ChildValue :: StringValue)
    end)
    for _, ChildValue in self.EnumTypesFolder:GetChildren() do
        self:SetUpEnumValue(ChildValue :: StringValue)
    end

    --Return the object.
    return (self :: any) :: Types.Registry
end

--[[
Returns a replicatable Cmdr data table from
Nexus Admin command data.
--]]
function Registry:GetReplicatableCmdrData(CommandData: Types.NexusAdminCommandData): Types.NexusAdminCommandData
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
            for i = 2, #CommandData.Keyword do
                table.insert(Data.Aliases, CommandData.Keyword[i])
            end
        end
    end

    --Return the data.
    return (Data :: any) :: Types.NexusAdminCommandData
end

--[[
Performs the BeforeRun verifications
of a CommandContext. Returns a result if
the command can't be run.
--]]
function Registry:PerformBeforeRun(CommandContext: Types.CmdrCommandContext): (string?)
    --Get the command data.
    if not self.CommandsByGroup[CommandContext.Group] then
        return
    end
    local CommandData
    for _, NewCommandData in self.CommandsByGroup[CommandContext.Group] do
        local Names = NewCommandData.Name or NewCommandData.Keyword or ""
        if typeof(NewCommandData.Name or NewCommandData.Keyword) == "string" then
            Names = {Names}
        end
        for _, Name in Names do
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
    if CommandContext.Executor and not self.Authorization:IsPlayerAuthorized(CommandContext.Executor, CommandData.AdminLevel or 1) then
        return "You are not authorized to run this command."
    end
    return nil
end

--[[
Creates a run method for a given command.
--]]
function Registry:CreateRunMethod(CommandData: Types.NexusAdminCommandData): (Types.CmdrCommandContext, ... any) -> (string?)
    local CmdrData = self:GetReplicatableCmdrData(CommandData)
    return function(CommandContext: Types.CmdrCommandContext, ...): (string?)
        --Run the command.
        if CommandData.Run then
            return (CommandData :: any):Run(CommandContext,...)
        elseif (CommandData :: any).OnCommandInvoked then
            warn("Command.OnCommandInvoked(Player,BaseMessage,Arguments/ArgumentParser) (used in "..(CmdrData.Name or "")..") is deprecated as of V.2.0.0. Command:Run(CommandContext) should be used instead.")
            
            --Get the arguments string.
            local ArgumentsString = ""
            if string.find(CommandContext.RawText," ") then
                local StartIndex, _ = string.find(CommandContext.RawText, " ")
                ArgumentsString = string.sub(CommandContext.RawText, (StartIndex :: number) + 1)
            end

            --Call the function.
            if CommandData.Arguments then
                warn("Command.OnCommandInvoked with Arguments (used in "..(CmdrData.Name or "")..") is deprecated as of V.1.1.0. Command:Run(CommandContext) should be used instead.")
                return (CommandData :: any).OnCommandInvoked(CommandContext.Executor,CommandContext.RawText,unpack(ArgumentParser:StringToArguments(ArgumentsString,CommandData.Arguments,CommandContext.Executor,(CommandData :: any).IgnoreFilter)))
            else
                return (CommandData :: any).OnCommandInvoked(CommandContext.Executor,CommandContext.RawText,ArgumentParser:CreateParser(ArgumentsString,CommandContext.Executor))
            end
        end
        return nil
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
        for _, Prefix in Prefixes do
            self.Prefixes[string.lower(Prefix)] = true
            self.PrefixCommands[string.lower(Prefix..Data.Name)] = string.lower(Data.Name)
            for _, Alias in Data.Aliases do
                self.PrefixCommands[string.lower(Prefix..Alias)] = string.lower(Alias)
            end
        end
    end

    --Add the command data.
    if not self.CommandsByGroup[Data.Group] then
        self.CommandsByGroup[Data.Group] = {}
    end
    table.insert(self.CommandsByGroup[Data.Group], CommandData)
end

--[[
Internally sets up a StringValue as an enum type.
--]]
function Registry:SetUpEnumValue(ChildValue: StringValue): ()
    --Create the fuzzy finder.
    local FuzzyFinder = self.Cmdr.Util.MakeFuzzyFinder(self.HttpService:JSONDecode(ChildValue.Value))
    ChildValue.Changed:Connect(function()
        FuzzyFinder = self.Cmdr.Util.MakeFuzzyFinder(self.HttpService:JSONDecode(ChildValue.Value))
    end)

    --Register the types.
    self.Cmdr.Registry:RegisterType(ChildValue.Name, {
        Transform = function(Text, Executor)
            return FuzzyFinder(Text)
        end,
        Validate = function(Values)
            return #Values > 0, "No values were found matching that query."
        end,
        Autocomplete = function(Values)
            return Values
        end,
        Parse = function(Values)
            return Values[1]
        end,
    } :: any)
    self.Cmdr.Registry:RegisterType(ChildValue.Name.."s", {
        Listable = true,
        Transform = function(Text, Executor)
            return FuzzyFinder(Text)
        end,
        Validate = function(Values)
            return #Values > 0, "No values were found matching that query."
        end,
        Autocomplete = function(Values)
            return Values
        end,
        Parse = function(Values)
            return Values
        end,
    } :: any)
end

--[[
Adds an enum type (list of string options).
Can be re-called to change the options.
--]]
function Registry:AddEnumType(Name: string, Options: {string}): ()
    local ExistingValue: StringValue = self.EnumTypesFolder:FindFirstChild(Name)
    local OptionsJson = self.HttpService:JSONEncode(Options)
    if ExistingValue then
        ExistingValue.Value = OptionsJson
    else
        local NewValue = Instance.new("StringValue")
        NewValue.Name = Name
        NewValue.Value = OptionsJson
        NewValue.Parent = (self :: any).EnumTypesFolder
    end
end



return (Registry :: any) :: Types.Registry