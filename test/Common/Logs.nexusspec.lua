--[[
TheNexusAvenger

Tests the Logs class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local LogsUnitTest = NexusUnitTesting.UnitTest:Extend()

local Logs = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Logs"))



--[[
Sets up the unit test.
--]]
function LogsUnitTest:Setup()
	--Create the component under testing.
	self.CuT = Logs.new(3)
end

--[[
Tests the Add method.
--]]
NexusUnitTesting:RegisterUnitTest(LogsUnitTest.new("Add"):SetRun(function(self)
    self:AssertEquals(self.CuT:GetLogs(),{})

    self.CuT:Add("Log 1")
    self:AssertEquals(self.CuT:GetLogs(),{"Log 1"})
    self.CuT:Add("Log 2")
    self:AssertEquals(self.CuT:GetLogs(),{"Log 2","Log 1"})
    self.CuT:Add("Log 3")
    self:AssertEquals(self.CuT:GetLogs(),{"Log 3","Log 2","Log 1"})
    self.CuT:Add("Log 4")
    self:AssertEquals(self.CuT:GetLogs(),{"Log 4","Log 3","Log 2"})
end))



return true