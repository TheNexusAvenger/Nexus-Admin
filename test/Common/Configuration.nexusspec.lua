--[[
TheNexusAvenger

Tests the Configuration class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local ConfigurationUnitTest = NexusUnitTesting.UnitTest:Extend()

local Configuration = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Configuration"))



--[[
Sets up the unit test.
--]]
function ConfigurationUnitTest:Setup()
    --Create the component under testing.
    self.CuT = Configuration.new({
        BuildUtilityLevel = 3,
        CommandLevelOverrides = {
            BuildUtility = {
                clearterrain = 4,
                s = 5,
                insert = nil,
            },
        }
    })
end

--[[
Tests the GetRaw method.
--]]
NexusUnitTesting:RegisterUnitTest(ConfigurationUnitTest.new("GetRaw"):SetRun(function(self)
    --Test with a given configration.
    local Config = {}
    local CuT = Configuration.new(Config)
    self:AssertSame(CuT:GetRaw(),Config)

    --Test with no given configuration.
    CuT = Configuration.new()
    self:AssertEquals(CuT:GetRaw(),{})
end))

--[[
Tests the GetCommandAdminLevel method.
--]]
NexusUnitTesting:RegisterUnitTest(ConfigurationUnitTest.new("GetCommandAdminLevel"):SetRun(function(self)
    --Test the default admin levels.
    self:AssertEquals(self.CuT:GetCommandAdminLevel("Administrative","unknown_command"),1)
    self:AssertEquals(self.CuT:GetCommandAdminLevel("BasicCommands","unknown_command"),1)
    self:AssertEquals(self.CuT:GetCommandAdminLevel("UsefulFunCommands","unknown_command"),2)
    self:AssertEquals(self.CuT:GetCommandAdminLevel("FunCommands","unknown_command"),3)
    self:AssertEquals(self.CuT:GetCommandAdminLevel("PersistentCommands","unknown_command"),4)

    --Test the overriden admin levels.
    self:AssertEquals(self.CuT:GetCommandAdminLevel("BuildUtility","unknown_command"),3)
    self:AssertEquals(self.CuT:GetCommandAdminLevel("BuildUtility","clearterrain"),4)
    self:AssertEquals(self.CuT:GetCommandAdminLevel("BuildUtility","s"),5)
    self:AssertEquals(self.CuT:GetCommandAdminLevel("BuildUtility","insert"),3)

    --Test a missing category.
    self:AssertErrors(function()
        self.CuT:GetCommandAdminLevel("UnknownCategory","unknown_command")
    end)
end))



return true