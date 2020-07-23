--[[
TheNexusAvenger

Server API for Nexus Admin.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")



--[[
Converts the number indexes to strings.
--]]
local function ConvertNumberIndexesToStrings(Array)
    local NewArray = {}
    for Key,Value in pairs(Array) do
        --Convert the key if it is a number.
        if type(Key) == "number" then
            Key = tostring(Key)
        end

        --Convert the value if it is an array.
        if type(Value) == "table" then
            Value = ConvertNumberIndexesToStrings(Value)
        end

        --Add the index.
        NewArray[Key] = Value
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

    --Copy the scripts to ReplicatedStorage.
    local NexusAdminClient = script:WaitForChild("Client"):Clone()
    NexusAdminClient.Name = "NexusAdminClient"
    NexusAdminClient.Parent = ReplicatedStorage

    local Common = script:WaitForChild("Common"):Clone()
    Common.Parent = NexusAdminClient

    local NexusInstance = script:WaitForChild("NexusInstance"):Clone()
    NexusInstance.Parent = NexusAdminClient

    local NexusButton = script:WaitForChild("NexusButton"):Clone()
    NexusButton.Parent = NexusAdminClient

    local LocalIncludedCommands = script:WaitForChild("IncludedCommands"):WaitForChild("Local"):Clone()
    LocalIncludedCommands.Name = "IncludedCommands"
    LocalIncludedCommands.Parent = NexusAdminClient

    local BaseCommand = script:WaitForChild("IncludedCommands"):WaitForChild("BaseCommand"):Clone()
    BaseCommand.Parent = LocalIncludedCommands

    --Initialize the resources.
    local Cmdr = require(script:WaitForChild("Cmdr"))
    local Configuration = require(script:WaitForChild("Common"):WaitForChild("Configuration")).new(ConfigurationTable)
    local Authorization = require(script:WaitForChild("Server"):WaitForChild("ServerAuthorization")).new(Configuration,EventContainer)
    Authorization:InitializePlayers()
    local Messages = require(script:WaitForChild("Server"):WaitForChild("ServerMessages")).new(EventContainer)
    local FeatureFlags = require(script:WaitForChild("Server"):WaitForChild("ServerFeatureFlags")).new(EventContainer)
    FeatureFlags:InitializeServices()
    local Replicator = require(script:WaitForChild("Server"):WaitForChild("Replicator")).new()
    local Filter = require(script:WaitForChild("Server"):WaitForChild("Filter")).new()
    local Time = require(script:WaitForChild("Common"):WaitForChild("Time")).new()
    local Logs = require(script:WaitForChild("Common"):WaitForChild("Logs")).new()
    local Registry = require(script:WaitForChild("Server"):WaitForChild("ServerRegistry")).new(Cmdr,Authorization,Messages,EventContainer)
    local Executor = require(script:WaitForChild("Common"):WaitForChild("Executor")).new(Cmdr,Registry)
    
    --Create the configuration fetching.
    local GetConfiguration = Instance.new("RemoteFunction")
    GetConfiguration.Name = "GetConfiguration"
    GetConfiguration.Parent = EventContainer

    function GetConfiguration.OnServerInvoke()
        return ConvertNumberIndexesToStrings(ConfigurationTable)
    end

    --Set the resouces.
    API.Types = {}
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
    API.FeatureFlags = FeatureFlags
    API.Version = Configuration.Version
	API.VersionNumberId = Configuration.VersionNumberId
    API.CmdrVersion = Configuration.CmdrVersion
	API.EventContainer = EventContainer
    API.AdminItemContainer = AdminItemContainer

    --Add the custom Cmdr types.
    for _,TypeModule in pairs(script:WaitForChild("Common"):WaitForChild("Types"):GetChildren()) do
        require(TypeModule)(API)
    end

    --Set the feature flag overrides.
    for Name,Value in pairs(Configuration.FeatureFlagOverrides) do
        FeatureFlags:SetFeatureFlag(Name,Value)
    end

    --Add the initial feature flags.
    FeatureFlags:AddFeatureFlag("UseNativeMessageGui",true)
    FeatureFlags:AddFeatureFlag("UseNativeHintGui",true)
    FeatureFlags:AddFeatureFlag("UseCmdrCommandBar",true)
    FeatureFlags:AddFeatureFlag("DisplayAdminLevelNotifications",true)
    FeatureFlags:AddFeatureFlag("AllowChatCommandExecuting",true)

    --Mark the system as loaded.
    Loaded = true
end

--[[
Loads the including commands.
--]]
function API:LoadIncludedCommands()
    local Categories = {"Administrative","BasicCommands","BuildUtility","UsefulFun","Fun","Persistent"}
    for _,Category in pairs(Categories) do
        --Add the scripts.
		local Folder = script:WaitForChild("IncludedCommands"):WaitForChild(Category)
		for _,Module in pairs(Folder:GetChildren()) do
			if Module:IsA("ModuleScript") then
				self.Registry:LoadCommand(require(Module).new():Flatten())
			end
		end

		--Connect adding new scripts.
		Folder.ChildAdded:Connect(function(Module)
			if Module:IsA("ModuleScript") then
				self.Registry:LoadCommand(require(Module).new():Flatten())
			end
		end)
    end
end

--[[
Loads the client loader to all clients.
--]]
function API:LoadClientLoader()
    self.Replicator:GiveStarterScript(script:WaitForChild("Resources"):WaitForChild("NexusAdminClientLoader"))
end

--[[
Returns if Nexus Admin is loaded.
--]]
function API:GetAdminLoaded()
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
    return API.Replicator:GiveScriptToPlayer(Player,Script)
end

function API.BindScriptToSpawn(Script)
    warn("NexusAdminServerAPI.BindScriptToSpawn(Script) is deprecated as of V.2.0.0. Please use NexusAdminServerAPI.Replicator:GiveStarterScript(Script) instead.")
    return API.Replicator:GiveStarterScript(Script)
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
setmetatable(API,{
    __index = function(_,Index)
        local Result = rawget(API,Index)

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
return API