--[[
TheNexusAvenger

Server API for Nexus Admin.
--]]
--!strict

local CMDR_OVERRIDE_ADMIN_LEVELS = {
    --Provides DataStore access.
    var = 0,
    varSet = 0,
}



local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(script:WaitForChild("Types"))



--[[
Converts the number indexes to strings.
--]]
local function ConvertNumberIndexesToStrings(Array: any): {[string]: any}
    local NewArray = {}
    for Key,Value in Array do
        --Convert the value if it is an array.
        if type(Value) == "table" then
            Value = ConvertNumberIndexesToStrings(Value)
        end

        --Add the index.
        NewArray[tostring(Key)] = Value
    end

    return NewArray
end



--Create the base API.
local Loaded = false
local API = {}

--[[
Loads Nexus Admin.
--]]
function API:Load(ConfigurationTable)
    --Create the containers.
    local EventContainer = Instance.new("Folder")
    EventContainer.Name = "NexusAdminEvents"
    EventContainer.Parent = ReplicatedStorage

    local AdminItemContainer = Instance.new("Folder")
    AdminItemContainer.Name = "NexusAdminItemContainer"
    AdminItemContainer.Parent = Workspace

    --Prepare the scripts to ReplicatedStorage.
    local NexusAdminClient = script:WaitForChild("Client"):Clone()
    NexusAdminClient.Name = "NexusAdminClient"

    NexusAdminClient:WaitForChild("Types"):Destroy()
    local TypesModule = script:WaitForChild("Types"):Clone()
    TypesModule.Parent = NexusAdminClient

    local Common = script:WaitForChild("Common"):Clone()
    Common.Parent = NexusAdminClient

    local NexusInstance = script:WaitForChild("NexusInstance"):Clone()
    NexusInstance.Parent = NexusAdminClient

    local NexusButton = script:WaitForChild("NexusButton"):Clone()
    NexusButton.Parent = NexusAdminClient

    local LocalIncludedCommands = script:WaitForChild("IncludedCommands"):WaitForChild("Local"):Clone()
    LocalIncludedCommands.Name = "IncludedCommands"
    LocalIncludedCommands.Parent = NexusAdminClient

    local IncludedCommandUtil = script:WaitForChild("IncludedCommands"):WaitForChild("IncludedCommandUtil"):Clone()
    IncludedCommandUtil.Parent = LocalIncludedCommands

    local BaseCommand = script:WaitForChild("IncludedCommands"):WaitForChild("BaseCommand"):Clone()
    BaseCommand.Parent = LocalIncludedCommands

    --Initialize the resources.
    local Cmdr = require(script:WaitForChild("Cmdr"))
    local Configuration = require(script:WaitForChild("Common"):WaitForChild("Configuration")).new(ConfigurationTable)
    local Authorization = require(script:WaitForChild("Server"):WaitForChild("ServerAuthorization")).new(Configuration, EventContainer);
    (Authorization :: {InitializePlayers: (self: Types.Authorization) -> ()} & Types.Authorization):InitializePlayers()
    local Messages = require(script:WaitForChild("Server"):WaitForChild("ServerMessages")).new(EventContainer)
    local FeatureFlagsModule = script:WaitForChild("NexusFeatureFlags")
    FeatureFlagsModule.Parent = NexusAdminClient
    local FeatureFlags = require(FeatureFlagsModule)
    local Replicator = require(script:WaitForChild("Server"):WaitForChild("Replicator")).new()
    local Filter = require(script:WaitForChild("Server"):WaitForChild("ServerFilter")).new()
    local Time = require(script:WaitForChild("Common"):WaitForChild("Time"))
    local Logs = require(script:WaitForChild("Common"):WaitForChild("Logs")).new()
    local Registry = require(script:WaitForChild("Server"):WaitForChild("ServerRegistry")).new(Cmdr, Configuration, Authorization, Messages, Logs, Time, Filter, EventContainer)
    local LogsRegistry = require(script:WaitForChild("Server"):WaitForChild("ServerLogsRegistry")).new(Authorization, EventContainer)
    local Executor = require(script:WaitForChild("Common"):WaitForChild("Executor")).new(Cmdr, Registry)

    --Create the configuration fetching.
    local GetConfiguration = Instance.new("RemoteFunction")
    GetConfiguration.Name = "GetConfiguration"
    GetConfiguration.Parent = EventContainer

    function GetConfiguration.OnServerInvoke()
        return ConvertNumberIndexesToStrings(ConfigurationTable)
    end

    --Set the resouces.
    API.Types = {}
    API.CommandData = {}
    API.Cmdr = Cmdr
    API.Configuration = Configuration
    API.Authorization = Authorization
    API.Executor = Executor
    API.Messages = Messages
    API.Filter = Filter
    API.Time = Time
    API.Replicator = Replicator
    API.Logs = Logs
    API.Registry = Registry
    API.LogsRegistry = LogsRegistry
    API.FeatureFlags = FeatureFlags
    API.Version = Configuration.Version
    API.VersionNumberId = Configuration.VersionNumberId
    API.CmdrVersion = Configuration.CmdrVersion
    API.EventContainer = EventContainer
    API.AdminItemContainer = AdminItemContainer

    --Add the custom Cmdr types.
    for _, TypeModule in script:WaitForChild("Common"):WaitForChild("Types"):GetChildren() do
        (require(TypeModule) :: (Types.NexusAdminApiServer) -> ())(API :: any)
    end

    --Set the feature flag overrides.
    for Name, Value in Configuration.FeatureFlagOverrides do
        FeatureFlags:SetFeatureFlag(Name, Value)
    end

    --Add the initial feature flags.
    FeatureFlags:AddFeatureFlag("UseNativeMessageGui", true)
    FeatureFlags:AddFeatureFlag("UseNativeHintGui", true)
    FeatureFlags:AddFeatureFlag("UseNativeNotificationGui", true)
    FeatureFlags:AddFeatureFlag("DisplayAdminLevelNotifications", true)
    FeatureFlags:AddFeatureFlag("AllowChatCommandExecuting", true)

    --Mark the system as loaded.
    NexusAdminClient.Parent = ReplicatedStorage
    Loaded = true
end

--[[
Loads the including commands.
--]]
function API:LoadIncludedCommands(): ()
    --Load the Nexus Admin commands.
    local IncludedCommands = ReplicatedStorage:WaitForChild("NexusAdminClient"):WaitForChild("IncludedCommands")
    local Categories = {"Administrative", "BasicCommands", "BuildUtility", "Cmdr", "UsefulFun", "Fun", "Persistent"}
    for _, Category in Categories do
        --Add the scripts.
        local Folder = script:WaitForChild("IncludedCommands"):WaitForChild(Category)
        for _, Module in Folder:GetChildren() do
            if not Module:IsA("ModuleScript") then return end
            self.Registry:RegisterIncludedCommand(Module, self, IncludedCommands)
        end

        --Connect adding new scripts.
        Folder.ChildAdded:Connect(function(Module: Instance): ()
            if not Module:IsA("ModuleScript") then return end
            self.Registry:RegisterIncludedCommand(Module, self, IncludedCommands)
        end)
    end

    --Load the Cmdr utility commands.
    local CmdrUtilityCommands = script:WaitForChild("Cmdr"):WaitForChild("Server commands"):WaitForChild("Utility")
    local CmdrCommandsToLoad = script:WaitForChild("Cmdr"):WaitForChild("Server commands"):WaitForChild("Utility"):GetChildren()
    table.insert(CmdrCommandsToLoad, script:WaitForChild("Cmdr"):WaitForChild("Server commands"):WaitForChild("help"))
    for _, CommandScript in CmdrCommandsToLoad do
        if CommandScript:IsA("ModuleScript") and not CommandScript.Name:find("Server") then
            local ServerCommandScript = CmdrUtilityCommands:FindFirstChild(CommandScript.Name.."Server")
            local CommandData = require(CommandScript) :: Types.NexusAdminCommandData
            CommandData.AutoExec = nil --AutoExec is handled on the client.
            CommandData.AdminLevel = CMDR_OVERRIDE_ADMIN_LEVELS[CommandScript.Name]
            if ServerCommandScript then
                CommandData.Run = require(ServerCommandScript) :: (CommandContext: Types.CmdrCommandContext, ...any) -> (string?)
            end
            if CommandData.Run then
                local BaseRun = CommandData.Run
                CommandData.Run = function(_,...)
                    return BaseRun(...)
                end
            end
            if CommandData.ClientRun then
                local BaseRun = CommandData.ClientRun
                CommandData.ClientRun = function(_,...)
                    return BaseRun(...)
                end
            end
            self.Registry:LoadCommand(CommandData)
            CommandScript.Parent = self.Cmdr.ReplicatedRoot.Commands
        end
    end
end

--[[
Loads the client loader to all clients.
--]]
function API:LoadClientLoader(): ()
    self.Replicator:GiveStarterScript(script:WaitForChild("Resources"):WaitForChild("NexusAdminClientLoader"))
end

--[[
Returns if Nexus Admin is loaded.
--]]
function API:GetAdminLoaded(): boolean
    return Loaded
end

--Add the API fetchers.
function _G.NexusAdmin_GetServerAPI()
    return API
end

function _G.GetNexusAdminServerAPI()
    return API
end

--Add the deprecated API.
function API.GetConfig()
    warn("NexusAdminServerAPI.GetConfig() is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Configuration:GetRaw() instead.")
    return API.Configuration:GetRaw()
end

function API.AddCommandToLoad(Table)
    warn("NexusAdminServerAPI.AddCommandToLoad(CommandTable) is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Registry:LoadCommand(CommandTable) instead.")
    API.Registry:LoadCommand(Table)
end

function API.GetLogs()
    warn("NexusAdminServerAPI.GetLogs() is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Logs:GetLogs() instead.")
    return API.Logs:GetLogs()
end

function API.AddToLogs(Log)
    warn("NexusAdminServerAPI.AddToLogs(Log) is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Logs:Add(Log) instead.")
    return API.Logs:Add(Log)
end

function API.GetAdmins(GetRaw)
    error("NexusAdminServerAPI.GetAdmins(GetRaw) is removed as of V.2.0.0. If needed, NexusAdminServerAPI.Authorization.AdminLevels can be used.")
end

function API.GetAdminLevel(Player)
    warn("NexusAdminServerAPI.GetAdminLevel(Player) is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Authorization:GetAdminLevel(Player) instead.")
    return API.Authorization:GetAdminLevel(Player)
end

function API.InvokeCommand(Command,ArgumentString,ReferencePlayer)
    warn("NexusAdminServerAPI.InvokeCommand(Command,ArgumentString,ReferencePlayer) is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Executor:ExecuteCommandWithPrefix(Command,ReferencePlayer) instead.")
    return API.Executor:ExecuteCommandWithPrefix(Command.." "..ArgumentString,ReferencePlayer)
end

function API.DisplayHint(Player,Message,DisplayTime)
    warn("NexusAdminServerAPI.DisplayHint(Player,Message,DisplayTime) is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Messages:DisplayHint(Player,Message,DisplayTime) instead.")
    return API.Messages:DisplayHint(Player,Message,DisplayTime)
end

function API.DisplayMessage(Player,TopText,Message,DisplayTime)
    warn("NexusAdminServerAPI.DisplayMessage(Player,TopText,Message,DisplayTime) is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Messages:DisplayMessage(Player,TopText,Message,DisplayTime) instead.")
    return API.Messages:DisplayMessage(Player,TopText,Message,DisplayTime)
end

function API.AddScriptToPlayer(Player,Script)
    warn("NexusAdminServerAPI.AddScriptToPlayer(Player,Script) is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Replicator:GiveScriptToPlayer(Player,Script) instead.")
    API.Replicator:GiveScriptToPlayer(Player, Script)
end

function API.BindScriptToSpawn(Script)
    warn("NexusAdminServerAPI.BindScriptToSpawn(Script) is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Replicator:GiveStarterScript(Script) instead.")
    API.Replicator:GiveStarterScript(Script)
end

function API.FilterStringAsync(String,PlayerFrom,PlayerTo)
    warn("NexusAdminServerAPI.FilterStringAsync(String,PlayerFrom,PlayerTo) is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Filter:FilterString(String,PlayerFrom,PlayerTo) instead.")
    return API.Filter:FilterString(String,PlayerFrom,PlayerTo)
end

function API.GetTimeString()
    warn("NexusAdminServerAPI.GetTimeString() is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Time:GetTimeString() instead.")
    return API.Time:GetTimeString()
end

--Set the metatable for throwing errors for when the system is not loaded.
setmetatable(API, {
    __index = function(_, Index: string)
        local Result = rawget(API, Index)

        --Throw an error if the result doesn't exist.
        if Result == nil then
            if Loaded then
                error("\""..Index.."\" is not a valid member of Nexus Admin.")
            else
                error("Nexus Admin has not been loaded. Call NexusAdmin:Load(ConfigurationTable) before indexing \""..Index.."\".")
            end
        end

        --Return the result.
        return Result
    end
})



--Return the API.
return (API :: any) :: Types.NexusAdminApiServer