--[[
TheNexusAvenger

Tests the ServerFeatureFlags class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local ServerFeatureFlagsUnitTest = NexusUnitTesting.UnitTest:Extend()

local ServerFeatureFlags = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Server"):WaitForChild("ServerFeatureFlags"))



--[[
Sets up the unit test.
--]]
function ServerFeatureFlagsUnitTest:Setup()
	--Create the components under testing.
    self.CuT1 = ServerFeatureFlags.new()
    self.CuT2 = ServerFeatureFlags.new()
    
    --Mock the MessagingService.
    self.MessagingServiceCalls = 0
    self.MessagingServiceCallbacks = {}
    self.CuT1.MessagingService = {
        PublishAsync = function(_,_,Message)
            self.MessagingServiceCalls = self.MessagingServiceCalls + 1
            for _,Callback in pairs(self.MessagingServiceCallbacks) do
                Callback(Message,os.time())
            end
        end,
        SubscribeAsync = function(_,_,Callback)
            table.insert(self.MessagingServiceCallbacks,Callback)
        end,
    }
    self.CuT2.MessagingService = self.CuT1.MessagingService

    --Mock the DataStoreService.
    self.DataStoreSetCalls = 0
    self.CurrentData = nil
    self.CuT1.DataStoreService = {
        GetDataStore = function()
            return {
                GetAsync = function(_,_)
                    return self.CurrentData
                end,
                SetAsync = function(_,_,Data)
                    self.DataStoreSetCalls = self.DataStoreSetCalls + 1
                    self.CurrentData = Data
                end,
                UpdateAsync = function(_,Key,Callback)
                    self.CuT1.DataStoreService:GetDataStore():SetAsync(Key,Callback(self.CurrentData))
                end,
            }
        end
    }
    self.CuT2.DataStoreService = self.CuT1.DataStoreService

    --Start the services.
    self.CuT1:InitializeServices()
    self.CuT2:InitializeServices()
end

--[[
Tests the SetFeatureFlag method.
--]]
NexusUnitTesting:RegisterUnitTest(ServerFeatureFlagsUnitTest.new("SetFeatureFlag"):SetRun(function(self)
    --Connect the events.
    local GeneralChanges1 = {}
    local SpecificChanges1 = {}
    local GeneralChanges2 = {}
    local SpecificChanges2 = {}
    self.CuT1.FeatureFlagChanged:Connect(function(Name,Value)
        table.insert(GeneralChanges1,{Name,Value})
    end)
    self.CuT2.FeatureFlagChanged:Connect(function(Name,Value)
        table.insert(GeneralChanges2,{Name,Value})
    end)
    self.CuT1:GetFeatureFlagChangedEvent("TestFeatureFlag1"):Connect(function(Value)
        table.insert(SpecificChanges1,Value)
    end)
    self.CuT2:GetFeatureFlagChangedEvent("TestFeatureFlag1"):Connect(function(Value)
        table.insert(SpecificChanges2,Value)
    end)

    --Set new flags and assert no network calls were made.
    self.CuT1:SetFeatureFlag("TestFeatureFlag1",true)
    self.CuT1:SetFeatureFlag("TestFeatureFlag2",false)
    self.CuT2:SetFeatureFlag("TestFeatureFlag1",true)
    self.CuT2:SetFeatureFlag("TestFeatureFlag2",false)
    self:AssertEquals(self.MessagingServiceCalls,0,"Messaging service was used.")
    self:AssertEquals(self.DataStoreSetCalls,0,"DataStore service was used.")
    self:AssertEquals(self.CurrentData,nil,"DataStore data was set.")
    self:AssertEquals(GeneralChanges1,{},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges1,{},"Event was invoked correctly.")
    self:AssertEquals(GeneralChanges2,{},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges2,{},"Event was invoked correctly.")

    --Set a flag to the same value and assert no network calls were made.
    self.CuT1:SetFeatureFlag("TestFeatureFlag1",true)
    wait()
    self:AssertEquals(self.MessagingServiceCalls,0,"Messaging service was used.")
    self:AssertEquals(self.DataStoreSetCalls,0,"DataStore service was used.")
    self:AssertEquals(self.CurrentData,nil,"DataStore data was set.")
    self:AssertEquals(GeneralChanges1,{},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges1,{},"Event was invoked correctly.")
    self:AssertEquals(GeneralChanges2,{},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges2,{},"Event was invoked correctly.")

    --Change a flag and assert it was replicated.
    self.CuT1:SetFeatureFlag("TestFeatureFlag1",false)
    wait()
    self:AssertEquals(self.CuT1:GetFeatureFlag("TestFeatureFlag1"),false,"Local feature flag value is incorrect.")
    self:AssertEquals(self.CuT2:GetFeatureFlag("TestFeatureFlag1"),false,"Replicated feature flag value is incorrect.")
    self:AssertEquals(self.MessagingServiceCalls,1,"Messaging service was used an incorrect amount of times.")
    self:AssertEquals(self.DataStoreSetCalls,1,"DataStore service was used an incorrect amount of times.")
    self:AssertEquals(self.CurrentData,"{\"TestFeatureFlag1\":false}","DataStore data was set.")
    self:AssertEquals(GeneralChanges1,{{"TestFeatureFlag1",false}},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges1,{false},"Event was invoked correctly.")
    self:AssertEquals(GeneralChanges2,{{"TestFeatureFlag1",false}},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges2,{false},"Event was invoked correctly.")

    --Revert a flag and assert it was replicated.
    self.CuT1:SetFeatureFlag("TestFeatureFlag1",true)
    wait()
    self:AssertEquals(self.CuT1:GetFeatureFlag("TestFeatureFlag1"),true,"Local feature flag value is incorrect.")
    self:AssertEquals(self.CuT2:GetFeatureFlag("TestFeatureFlag1"),true,"Replicated feature flag value is incorrect.")
    self:AssertEquals(self.MessagingServiceCalls,2,"Messaging service was used an incorrect amount of times.")
    self:AssertEquals(self.DataStoreSetCalls,2,"DataStore service was used an incorrect amount of times.")
    self:AssertEquals(self.CurrentData,"[]","DataStore data was set.")
    self:AssertEquals(GeneralChanges1,{{"TestFeatureFlag1",false},{"TestFeatureFlag1",true}},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges1,{false,true},"Event was invoked correctly.")
    self:AssertEquals(GeneralChanges2,{{"TestFeatureFlag1",false},{"TestFeatureFlag1",true}},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges2,{false,true},"Event was invoked correctly.")

    --Change 2 flags and assert it was replicated.
    self.CuT1:SetFeatureFlag("TestFeatureFlag1",false)
    self.CuT1:SetFeatureFlag("TestFeatureFlag2",true)
    wait()
    self:AssertEquals(self.CuT1:GetFeatureFlag("TestFeatureFlag1"),false,"Local feature flag value is incorrect.")
    self:AssertEquals(self.CuT2:GetFeatureFlag("TestFeatureFlag1"),false,"Replicated feature flag value is incorrect.")
    self:AssertEquals(self.CuT1:GetFeatureFlag("TestFeatureFlag2"),true,"Local feature flag value is incorrect.")
    self:AssertEquals(self.CuT2:GetFeatureFlag("TestFeatureFlag2"),true,"Replicated feature flag value is incorrect.")
    self:AssertEquals(self.MessagingServiceCalls,4,"Messaging service was used an incorrect amount of times.")
    self:AssertEquals(self.DataStoreSetCalls,4,"DataStore service was used an incorrect amount of times.")
    self:AssertEquals(self.MessagingServiceCalls,4,"Messaging service was used an incorrect amount of times.")
    self:AssertEquals(self.DataStoreSetCalls,4,"DataStore service was used an incorrect amount of times.")
    self:AssertEquals(self.CurrentData,"{\"TestFeatureFlag1\":false,\"TestFeatureFlag2\":true}","DataStore data was set.")
    self:AssertEquals(GeneralChanges1,{{"TestFeatureFlag1",false},{"TestFeatureFlag1",true},{"TestFeatureFlag1",false},{"TestFeatureFlag2",true}},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges1,{false,true,false},"Event was invoked correctly.")
    self:AssertEquals(GeneralChanges2,{{"TestFeatureFlag1",false},{"TestFeatureFlag1",true},{"TestFeatureFlag1",false},{"TestFeatureFlag2",true}},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges2,{false,true,false},"Event was invoked correctly.")
end))



return true