--[[
TheNexusAvenger

Tests the BaseCommand class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local BaseCommandUnitTest = NexusUnitTesting.UnitTest:Extend()

local BaseCommand = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("IncludedCommands"):WaitForChild("BaseCommand"))



--[[
Sets up the unit test.
--]]
function BaseCommandUnitTest:Setup()
    --Create the component under testing.
    self.CuT = BaseCommand.new("Test","Test","Test")
end

--[[
Tests the GetRemainingString method.
--]]
NexusUnitTesting:RegisterUnitTest(BaseCommandUnitTest.new("GetRemainingString"):SetRun(function(self)
    --Assert normal strings are valid.
    self:AssertEquals(self.CuT:GetRemainingString("Test1 Test2 Test3",1),"Test2 Test3")
    self:AssertEquals(self.CuT:GetRemainingString("Test1 Test2 Test3",2),"Test3")

    --Assert strings with extra spaces are valid.
    self:AssertEquals(self.CuT:GetRemainingString("   Test1 Test2 Test3",1),"Test2 Test3")
    self:AssertEquals(self.CuT:GetRemainingString("   Test1 Test2 Test3",2),"Test3")
    self:AssertEquals(self.CuT:GetRemainingString(" Test1 Test2 Test3",1),"Test2 Test3")
    self:AssertEquals(self.CuT:GetRemainingString(" Test1 Test2 Test3",2),"Test3")
    self:AssertEquals(self.CuT:GetRemainingString("Test1   Test2   Test3",1),"Test2   Test3")
    self:AssertEquals(self.CuT:GetRemainingString("Test1   Test2   Test3",2),"Test3")
    
    --Assert strings with quotes.
    self:AssertEquals(self.CuT:GetRemainingString("\"Test 1\" \"Test 2\" \"Test 3\"",1),"\"Test 2\" \"Test 3\"")
    self:AssertEquals(self.CuT:GetRemainingString("\"Test 1\" \"Test 2\" \"Test 3\"",2),"\"Test 3\"")

    --Assert empty cases return.
    self:AssertEquals(self.CuT:GetRemainingString("Test1 Test2 Test3",3),"")
    self:AssertEquals(self.CuT:GetRemainingString("Test1 Test2 Test3",4),"")
    self:AssertEquals(self.CuT:GetRemainingString("Test1 Test2 Test3",0),"Test1 Test2 Test3")
end))



return true