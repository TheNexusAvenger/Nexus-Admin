--[[
TheNexusAvenger

Tests the FeatureFlags class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local FeatureFlagsUnitTest = NexusUnitTesting.UnitTest:Extend()

local FeatureFlags = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("FeatureFlags"))



--[[
Sets up the unit test.
--]]
function FeatureFlagsUnitTest:Setup()
	--Create the component under testing.
	self.CuT = FeatureFlags.new()
end

--[[
Tests the AddFeatureFlag method.
--]]
NexusUnitTesting:RegisterUnitTest(FeatureFlagsUnitTest.new("AddFeatureFlag"):SetRun(function(self)
    --Add a new feature flag and assert it was added.
    self.CuT:AddFeatureFlag("TestFeatureFlag",false)
    self:AssertEquals(self.CuT:GetFeatureFlag("TestFeatureFlag"),false,"Feature flag not set.")

    --Re-add a feature flag and assert it wasn't overriden.
    self.CuT:AddFeatureFlag("TestFeatureFlag",true)
    self:AssertEquals(self.CuT:GetFeatureFlag("TestFeatureFlag"),false,"Feature flag was overriden.")
end))

--[[
Tests the SetFeatureFlag method.
--]]
NexusUnitTesting:RegisterUnitTest(FeatureFlagsUnitTest.new("SetFeatureFlag"):SetRun(function(self)
    --Connect the events.
    local GeneralChanges = {}
    local SpecificChanges = {}
    self.CuT.FeatureFlagChanged:Connect(function(Name,Value)
        table.insert(GeneralChanges,{Name,Value})
    end)
    self.CuT:GetFeatureFlagChangedEvent("TestFeatureFlag1"):Connect(function(Value)
        table.insert(SpecificChanges,Value)
    end)

    --Set a new feature flag and assert it was set correctly.
    self.CuT:SetFeatureFlag("TestFeatureFlag1","Value1")
    wait()
    self:AssertEquals(self.CuT:GetFeatureFlag("TestFeatureFlag1"),"Value1","Feature flag not set correctly.")
    self:AssertEquals(GeneralChanges,{},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges,{},"Event was invoked correctly.")

    --Set a existing feature flag and assert it was set correctly.
    self.CuT:SetFeatureFlag("TestFeatureFlag1","Value2")
    wait()
    self:AssertEquals(self.CuT:GetFeatureFlag("TestFeatureFlag1"),"Value2","Feature flag not set correctly.")
    self:AssertEquals(GeneralChanges,{{"TestFeatureFlag1","Value2"}},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges,{"Value2"},"Event was invoked correctly.")

    --Set a existing feature flag to the existing value and assert it was set correctly.
    self.CuT:SetFeatureFlag("TestFeatureFlag1","Value2")
    wait()
    self:AssertEquals(self.CuT:GetFeatureFlag("TestFeatureFlag1"),"Value2","Feature flag not set correctly.")
    self:AssertEquals(GeneralChanges,{{"TestFeatureFlag1","Value2"}},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges,{"Value2"},"Event was invoked correctly.")

    --Set a new feature flag and assert it was set correctly.
    self.CuT:SetFeatureFlag("TestFeatureFlag2","Value1")
    wait()
    self:AssertEquals(self.CuT:GetFeatureFlag("TestFeatureFlag1"),"Value2","Feature flag not set correctly.")
    self:AssertEquals(self.CuT:GetFeatureFlag("TestFeatureFlag2"),"Value1","Feature flag not set correctly.")
    self:AssertEquals(GeneralChanges,{{"TestFeatureFlag1","Value2"}},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges,{"Value2"},"Event was invoked correctly.")

    --Set a existing feature flag and assert it was set correctly.
    self.CuT:SetFeatureFlag("TestFeatureFlag2","Value2")
    wait()
    self:AssertEquals(self.CuT:GetFeatureFlag("TestFeatureFlag1"),"Value2","Feature flag not set correctly.")
    self:AssertEquals(self.CuT:GetFeatureFlag("TestFeatureFlag2"),"Value2","Feature flag not set correctly.")
    self:AssertEquals(GeneralChanges,{{"TestFeatureFlag1","Value2"},{"TestFeatureFlag2","Value2"}},"Event was invoked correctly.")
    self:AssertEquals(SpecificChanges,{"Value2"},"Event was invoked correctly.")
end))



return true