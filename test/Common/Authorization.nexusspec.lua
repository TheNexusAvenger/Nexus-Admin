--[[
TheNexusAvenger

Tests the Authorization class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local AuthorizationUnitTest = NexusUnitTesting.UnitTest:Extend()

local Authorization = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Authorization"))
local Configuration = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Configuration"))



--[[
Sets up the unit test.
--]]
function AuthorizationUnitTest:Setup()
    --Create the component under testing.
    self.CuT = Authorization.new(Configuration.new())

    --Create the mock players.
    self.MockPlayers = {
        {UserId=1},
        {UserId=2},
        {UserId=3},
    }

    --Initialize some admin levels admin levels.
    self.CuT:SetAdminLevel(self.MockPlayers[1],-1)
    self.CuT:SetAdminLevel(self.MockPlayers[2],4)
end

--[[
Tests the GetAdminLevel method.
--]]
NexusUnitTesting:RegisterUnitTest(AuthorizationUnitTest.new("GetAdminLevel"):SetRun(function(self)
    --Assert that the admin levels are correct.
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[1]),-1)
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[2]),4)
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[3]),-1)

    --Set an admin level and assert that it is correct.
    self.CuT:SetAdminLevel(self.MockPlayers[2],5)
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[2]),5)
end))

--[[
Tests the IsPlayerAuthorized method.
--]]
NexusUnitTesting:RegisterUnitTest(AuthorizationUnitTest.new("IsPlayerAuthorized"):SetRun(function(self)
    --Assert the the authorizations are correct.
    self:AssertTrue(self.CuT:IsPlayerAuthorized(self.MockPlayers[1],-1))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[1],0))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[1],1))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[1],2))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[1],3))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[1],4))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[1],5))
    self:AssertTrue(self.CuT:IsPlayerAuthorized(self.MockPlayers[2],-1))
    self:AssertTrue(self.CuT:IsPlayerAuthorized(self.MockPlayers[2],0))
    self:AssertTrue(self.CuT:IsPlayerAuthorized(self.MockPlayers[2],1))
    self:AssertTrue(self.CuT:IsPlayerAuthorized(self.MockPlayers[2],2))
    self:AssertTrue(self.CuT:IsPlayerAuthorized(self.MockPlayers[2],3))
    self:AssertTrue(self.CuT:IsPlayerAuthorized(self.MockPlayers[2],4))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[2],5))
    self:AssertTrue(self.CuT:IsPlayerAuthorized(self.MockPlayers[3],-1))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[3],0))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[3],1))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[3],2))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[3],3))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[3],4))
    self:AssertFalse(self.CuT:IsPlayerAuthorized(self.MockPlayers[3],5))
end))

--[[
Tests the YieldForAdminLevel method.
--]]
NexusUnitTesting:RegisterUnitTest(AuthorizationUnitTest.new("YieldForAdminLevel"):SetRun(function(self)
    --Assert there is no yielding for existing admins.
    self:AssertEquals(self.CuT:YieldForAdminLevel(self.MockPlayers[1]),-1)
    self:AssertEquals(self.CuT:YieldForAdminLevel(self.MockPlayers[2]),4)

    --Yield for an admin level and assert it continues.
    local CalledPlayer,CalledAdminLevel
    self.CuT.AdminLevelChanged:Connect(function(Player,AdminLevel)
        CalledPlayer,CalledAdminLevel = Player,AdminLevel
    end)
    spawn(function()
        self.CuT:SetAdminLevel(self.MockPlayers[3],5)
    end)
    self:AssertEquals(self.CuT:YieldForAdminLevel(self.MockPlayers[3]),5)
end))



return true