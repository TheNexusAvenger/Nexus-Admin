--[[
TheNexusAvenger

Handles feature flags on the server.
--]]

local FeatureFlags = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("FeatureFlags"))

local ServerFeatureFlags = FeatureFlags:Extend()
ServerFeatureFlags:SetClassName("ServerFeatureFlags")



--[[
Creates a server feature flag instance.
--]]
function ServerFeatureFlags:__new(NexusAdminRemotes)
    self:InitializeSuper()
    
    self.MessagingService = game:GetService("MessagingService")
    self.DataStoreService = game:GetService("DataStoreService")
    self.HttpService = game:GetService("HttpService")

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

    --Connect on close to yield for saving.
    self.SavesPending = 0
    game:BindToClose(function()
        while self.SavesPending > 0 do wait() end
    end)
end

--[[
Initializes the services.
--]]
function ServerFeatureFlags:InitializeServices()
    --Initialize the messaging service.
    local Worked,Return = pcall(function()
        self.MessagingService:SubscribeAsync("NexusAdminFeatureFlagsChanged",function(Data)
            if Data == "" then
                self:UpdateFeatureFlags()
            else
                self:UpdateFeatureFlags(Data)
            end
        end)
    end)
    if not Worked then
        warn("Connecting to messaging service for Nexus Admin Feature Flag changes failed because "..tostring(Return))
    end

    --Initialize the existing DataStore fast flags.
    self:UpdateFeatureFlags()
end

--[[
Updates the feature flags from
the data store.
--]]
function ServerFeatureFlags:UpdateFeatureFlags(OverrideMessage)
    local Worked,Return = pcall(function()
        --Parse the message.
        if not OverrideMessage then
            OverrideMessage = self.DataStoreService:GetDataStore("NexusAdminFeatureFlags"):GetAsync("FeatureFlagOverrides")
            self.FeatureFlagsLoadedFromDataStores = true
        end
        local OverrideFastFlags = self.HttpService:JSONDecode(OverrideMessage or {})
        
        --Set the overrides.
        for Name,Value in pairs(OverrideFastFlags) do
            self.super:SetFeatureFlag(Name,Value)
            self.FeatureFlagChangedEvent:FireAllClients(Name,Value)
        end

        --Reset the defaults of the removed flags.
        if self.PreviousOverrideFastFlags then
            for Name,Value in pairs(self.PreviousOverrideFastFlags) do
                if OverrideFastFlags[Name] == nil then
                    self.super:SetFeatureFlag(Name,self.DefaultFeatureFlags[Name])
                    self.FeatureFlagChangedEvent:FireAllClients(Name,self.DefaultFeatureFlags[Name])
                end
            end
        end

        --Store the flags changed as the previous.
        self.PreviousOverrideFastFlags = OverrideFastFlags
    end)
end

--[[
Serializes the feature flags to the
data store.
--]]
function ServerFeatureFlags:SerializeFeatureFlags()
    --Return if the feature flags were not loaded.
    if not self.FeatureFlagsLoadedFromDataStores then
        warn("Saving feature flags ignored because they weren't initially loaded.")
        return
    end

    local Worked,Return = pcall(function()
        self.SavesPending = self.SavesPending + 1

        local FeatureFlagChangesJSON
        self.DataStoreService:GetDataStore("NexusAdminFeatureFlags"):UpdateAsync("FeatureFlagOverrides",function()
            --Determine the flags to save.
            local FeatureFlagChanges = {}
            for Name,Value in pairs(self.FeatureFlags) do
                if self.DefaultFeatureFlags[Name] ~= Value then
                    FeatureFlagChanges[Name] = Value
                end
            end

            --Return the JSON of the changes.
            FeatureFlagChangesJSON = self.HttpService:JSONEncode(FeatureFlagChanges)
            return FeatureFlagChangesJSON
        end)

        --Send a message that the feature flags were changed.
        if FeatureFlagChangesJSON then
            local Message = ""
            if string.len(FeatureFlagChangesJSON) < 950 then
                Message = FeatureFlagChangesJSON
            end
            self.MessagingService:PublishAsync("NexusAdminFeatureFlagsChanged",Message)
        end
    end)
    self.SavesPending = self.SavesPending - 1

    --Display a warning if the serialization failed.
    if not Worked then
        warn("Saving feature flags in DataStore failed because "..tostring(Return))
    end
end

--[[
Sets a feature flag value.
--]]
function ServerFeatureFlags:SetFeatureFlag(Name,Value,SkipSaving)
    local InitialValue = self:GetFeatureFlag(Name)
    self.super:SetFeatureFlag(Name,Value)
    self.FeatureFlagChangedEvent:FireAllClients(Name,Value)

    --Serialize the feature flags.
    if InitialValue ~= nil and InitialValue ~= Value and not SkipSaving then
        self:SerializeFeatureFlags()
    end
end



return ServerFeatureFlags