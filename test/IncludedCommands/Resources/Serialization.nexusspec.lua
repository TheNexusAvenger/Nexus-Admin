--[[
TheNexusAvenger

Tests the Serialization class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local BaseCommandUnitTest = NexusUnitTesting.UnitTest:Extend()

local Serialization = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("IncludedCommands"):WaitForChild("Resources"):WaitForChild("Serialization"))



--[[
Tests that the required DataType serializers exist.
--]]
NexusUnitTesting:RegisterUnitTest(BaseCommandUnitTest.new("CheckSerializers"):SetRun(function(self)
    Serialization:CheckSerializers()
end))



return true