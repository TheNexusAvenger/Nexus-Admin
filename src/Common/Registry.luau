--Base class for a command registry.
--!strict

local RunService = game:GetService("RunService")

local ArgumentParser = nil
local Types = require(script.Parent.Parent:WaitForChild("Types"))
local Authorization = require(script.Parent:WaitForChild("Authorization"))
local Configuration = require(script.Parent:WaitForChild("Configuration"))

local Registry = {}
Registry.__index = Registry

export type Registry = {
    Prefixes: {[string]: boolean},
    PrefixCommands: {[string]: string},
    CommandsByGroup: {[string]: {Types.NexusAdminCommandData}},
    Authorization: Authorization.Authorization,
    Configuration: Configuration.Configuration,
    Messages: Types.MessagesServer | Types.MessagesClient,
    Cmdr: Types.Cmdr,
    RunService: RunService,
    HttpService: HttpService,
    EnumTypesFolder: Folder,
} & typeof(setmetatable({}, Registry))



--[[
Creates the server registry.
--]]
function Registry.new(Authorization: Authorization.Authorization, Configuration: Configuration.Configuration, Messages: Types.MessagesServer | Types.MessagesClient, Cmdr: Types.Cmdr, NexusAdminRemotes: Folder): Registry
    local self = setmetatable({
        Prefixes = {},
        PrefixCommands = {},
        CommandsByGroup = {},
        Authorization = Authorization,
        Configuration = Configuration,
        Messages = Messages,
        Cmdr = Cmdr,
        RunService = game:GetService("RunService"),
        HttpService = game:GetService("HttpService"),   
    }, Registry) :: Registry

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
    return self
end

--[[
Returns a replicatable Cmdr data table from
Nexus Admin command data.
--]]
function Registry.GetReplicatableCmdrData(self: Registry, CommandData: Types.NexusAdminCommandData): Types.NexusAdminCommandData
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
function Registry.PerformBeforeRun(self: Registry, CommandContext: Types.CmdrCommandContext): (string?)
    --Get the command data.
    if not self.CommandsByGroup[CommandContext.Group] then
        return
    end
    local CommandData
    for _, NewCommandData in self.CommandsByGroup[CommandContext.Group] do
        local Names = NewCommandData.Name or NewCommandData.Keyword or ""
        if typeof(NewCommandData.Name or NewCommandData.Keyword) == "string" then
            Names = {Names} :: any
        end
        for _, Name in Names :: {string} do
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
function Registry.CreateRunMethod(self: Registry, CommandData: Types.NexusAdminCommandData): (Types.CmdrCommandContext, ... any) -> (string?)
    local CmdrData = self:GetReplicatableCmdrData(CommandData)
    if not ArgumentParser and not CommandData.Run and (CommandData :: any).OnCommandInvoked then
        warn(`Command.OnCommandInvoked(Player,BaseMessage,Arguments/ArgumentParser) (used in {CmdrData.Name or ""}) is deprecated as of V.2.0.0. Command:Run(CommandContext) should be used instead.`)
        ArgumentParser = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("ArgumentParser"))
    end

    return function(CommandContext: Types.CmdrCommandContext, ...): (string?)
        --Run the command.
        if CommandData.Run then
            return (CommandData :: any):Run(CommandContext, ...)
        elseif (CommandData :: any).OnCommandInvoked then
            --Get the arguments string.
            local ArgumentsString = ""
            if string.find(CommandContext.RawText," ") then
                local StartIndex, _ = string.find(CommandContext.RawText, " ")
                ArgumentsString = string.sub(CommandContext.RawText, (StartIndex :: number) + 1)
            end

            --Call the function.
            if CommandData.Arguments then
                warn(`Command.OnCommandInvoked with Arguments (used in {CmdrData.Name or ""}) is deprecated as of V.1.1.0. Command:Run(CommandContext) should be used instead.`)
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
function Registry.LoadCommand(self: Registry, CommandData: Types.NexusAdminCommandData)
    local Data = self:GetReplicatableCmdrData(CommandData)

    --Add the prefix commands.
    if CommandData.Prefix then
        --Get the prefixes.
        local Prefixes = CommandData.Prefix
        if type(Prefixes) == "string" then
            Prefixes = {Prefixes}
        end

        --Add the prefixes.
        for _, Prefix in Prefixes :: {string} do
            self.Prefixes[string.lower(Prefix)] = true
            self.PrefixCommands[string.lower(`{Prefix}{Data.Name}`)] = string.lower(Data.Name)
            for _, Alias in Data.Aliases do
                self.PrefixCommands[string.lower(`{Prefix}{Alias}`)] = string.lower(Alias)
            end
        end
    end

    --Add the command data.
    local Group = Data.Group :: string
    if not self.CommandsByGroup[Group] then
        self.CommandsByGroup[Group] = {}
    end
    table.insert(self.CommandsByGroup[Group], CommandData)
end

--[[
Registers an included command.
--]]
function Registry.RegisterIncludedCommand(self: Registry, ModuleScript: ModuleScript, Api: Types.NexusAdminApiServer | Types.NexusAdminApi, LocalCommandContainer: Folder?): ()
    --Add the missing data.
    local CommandData = require(ModuleScript) :: any
    if CommandData.Prefix then
        CommandData.Prefix = {self.Configuration.CommandPrefix, CommandData.Prefix}
    else
        CommandData.Prefix = self.Configuration.CommandPrefix
    end
    if not CommandData.AllowAllUsers then
        if type(CommandData.Keyword) == "table" then
            CommandData.AdminLevel = self.Configuration:GetCommandAdminLevel(CommandData.Category, CommandData.Keyword[1])
        else
            CommandData.AdminLevel = self.Configuration:GetCommandAdminLevel(CommandData.Category, CommandData.Keyword)
        end
    end
    CommandData.Arguments = CommandData.Arguments or {}

    --Replace the run command with an existing one.
    if RunService:IsClient() then
        local ExistingCommand = self.Cmdr.Registry.Commands[CommandData.Name]
        if ExistingCommand then
            CommandData.Run = ExistingCommand.ClientRun
        end
    end

    --Store the run function.
    local HasClientImplementation = (CommandData.ClientRun ~= nil or CommandData.ClientLoad ~= nil)
    if not HasClientImplementation and CommandData.Arguments then
        for _, Argument in CommandData.Arguments do
            if typeof(Argument) ~= "function" then continue end
            HasClientImplementation = true
            break
        end
    end
    local RunFunction = CommandData.Run or CommandData.ClientRun or function() end
    if RunService:IsServer() then
        RunFunction = CommandData.Run or CommandData.ServerRun or function() end
    end
    CommandData.Run = function(_, ...) return RunFunction(...) end
    CommandData.ClientRun = nil
    CommandData.ServerRun = nil

    --Load the command.
    if RunService:IsServer() and CommandData.ServerLoad then
        CommandData.ServerLoad(Api)
    elseif RunService:IsClient() and CommandData.ClientLoad then
        CommandData.ClientLoad(Api)
    end
    self:LoadCommand(CommandData)

    --Copy the module for the client.
    if HasClientImplementation and LocalCommandContainer then
        if not LocalCommandContainer:FindFirstChild(CommandData.Category) then
            local LocalCommandFolder = Instance.new("Folder")
            LocalCommandFolder.Name = CommandData.Category
            LocalCommandFolder.Parent = LocalCommandContainer
        end
        ModuleScript:Clone().Parent = LocalCommandContainer:FindFirstChild(CommandData.Category)
    end
end

--[[
Internally sets up a StringValue as an enum type.
--]]
function Registry.SetUpEnumValue(self: Registry, ChildValue: StringValue): ()
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
    self.Cmdr.Registry:RegisterType(`{ChildValue.Name}s`, {
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
function Registry.AddEnumType(self: Registry, Name: string, Options: {string}): ()
    local ExistingValue = self.EnumTypesFolder:FindFirstChild(Name) :: StringValue
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



return Registry