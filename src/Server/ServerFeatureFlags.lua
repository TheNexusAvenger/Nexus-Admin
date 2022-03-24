--[[
TheNexusAvenger

Handles feature flags on the server.
--]]

local FeatureFlags = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("FeatureFlags"))

local NexusDataStore = require(script.Parent.Parent:WaitForChild("NexusDataStore"))

local ServerFeatureFlags = FeatureFlags:Extend()
ServerFeatureFlags:SetClassName("ServerFeatureFlags")



--[[
Creates a server feature flag instance.
--]]
function ServerFeatureFlags:__new(NexusAdminRemotes)
    self:InitializeSuper()

    self.DataStoreService = game:GetService("DataStoreService")
    self.HttpService = game:GetService("HttpService")
    self.DataStoreConnectedFeatureFlags = {}

    --Create the remote objects.
    local FeatureFlagEvents = Instance.new("Folder")
    FeatureFlagEvents.Name = "FeatureFlagEvents"
    FeatureFlagEvents.Parent = NexusAdminRemotes

    local GetFeatureFlags = Instance.new("RemoteFunction")
    GetFeatureFlags.Name = "GetFeatureFlags"
    GetFeatureFlags.Parent = FeatureFlagEvents

    local FeatureFlagChanged = Instance.new("RemoteEvent")
    FeatureFlagChanged.Name = "FeatureFlagChanged"
    FeatureFlagChanged.Parent = FeatureFlagEvents
    self.FeatureFlagChangedEvent = FeatureFlagChanged

    --Connect the remote objects.
    function GetFeatureFlags.OnServerInvoke()
        return self.FeatureFlags
    end
end

--[[
Initializes the services.
--]]
function ServerFeatureFlags:InitializeServices()
    --Initialize the data store.
    pcall(function()
        --Get the data store.
        self.DataStore = NexusDataStore:GetDataStore("NexusAdminFeatureFlags", "FeatureFlagOverrides")

        --Convert the data if the data is JSON.
        --This is for migrating from before Nexus Data Store (before V.2.3.0).
        if typeof(self.DataStore.Data) == "string" then
            self.DataStore.Data = self.HttpService:JSONDecode(self.DataStore.Data)
            pcall(function()
                self.DataStoreService:GetDataStore("NexusAdminFeatureFlags"):SetAsync("FeatureFlagOverrides", self.DataStore.Data)
            end)
        end

        --Set the default values.
        for Name, Value in pairs(self.DataStore.Data) do
            self.super:SetFeatureFlag(Name, Value)
            self.FeatureFlagChangedEvent:FireAllClients(Name, Value)
        end
    end)
end

function ServerFeatureFlags:ConnectFeatureFlagDataChanges(Name)
    if self.DataStoreConnectedFeatureFlags[Name] then return end
    self.DataStoreConnectedFeatureFlags[Name] = true
    if not self.DataStore then return end

    --Connect the key updating.
    self.DataStore:OnUpdate(Name, function()
        local Value = self.DataStore:Get(Name)
        if Value == nil then
            Value = self.DefaultFeatureFlags[Name]
        end
        self:SetFeatureFlag(Name, Value, true)
    end)
end

--[[
Adds a feature flag if it wasn't set before.
--]]
function ServerFeatureFlags:AddFeatureFlag(Name, Value)
    self.super:AddFeatureFlag(Name, Value)
    self:ConnectFeatureFlagDataChanges(Name)
end

--[[
Sets a feature flag value.
--]]
function ServerFeatureFlags:SetFeatureFlag(Name, Value, SkipSaving)
    --Set the value.
    local InitialValue = self:GetFeatureFlag(Name)
    self.super:SetFeatureFlag(Name, Value)
    self.FeatureFlagChangedEvent:FireAllClients(Name, Value)
    self:ConnectFeatureFlagDataChanges(Name)

    --Save the feature flags.
    if InitialValue ~= nil and InitialValue ~= Value and not SkipSaving and self.DataStore then
        if Value ~= self.DefaultFeatureFlags[Name] then
            self.DataStore:Set(Name, Value)
        else
            self.DataStore:Set(Name, nil)
        end
    end
end



return ServerFeatureFlags