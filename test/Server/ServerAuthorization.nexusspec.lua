--[[
TheNexusAvenger

Tests the ServerAuthorization class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local ServerAuthorizationUnitTest = NexusUnitTesting.UnitTest:Extend()

local ServerAuthorization = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Server"):WaitForChild("ServerAuthorization"))
local Configuration = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Configuration"))



--[[
Sets up the unit test.
--]]
function ServerAuthorizationUnitTest:Setup()
    --Create the component under testing.
    self.CuT = ServerAuthorization.new(Configuration.new({
        Admins = {
            [2] = 3,
            [4] = 2,
            [5] = 2,
        },
        GroupAdminLevels = {
            [11] = {
                [20] = 1,
                [40] = 2,
                [60] = 3,
            }
        },
    }))

    --Set the game id and creator id.
    self.CuT.GameId = 1
    self.CuT.CreatorId = 7

    --Create the mock players.
    self.MockPlayers = {
        {UserId=1},
        {UserId=2},
        {UserId=3},
        {UserId=4},
        {UserId=5},
        {UserId=6},
        {UserId=25691148},
        {UserId=7},
    }
    
    --Mock the GroupService.
    self.CuT.GroupService = {
        GetGroupsAsync = function(self,Id)
            if Id == 3 then
                return {
                    {
                        Id = 12,
                        Rank = 70,
                    },
                }
            elseif Id == 4 then
                return {
                    {
                        Id = 11,
                        Rank = 70,
                    },
                }
            elseif Id == 5 then
                return {
                    {
                        Id = 11,
                        Rank = 70,
                    },
                }
            elseif Id == 6 then
                return {
                    {
                        Id = 11,
                        Rank = 40,
                    },
                }
            else
                return {}
            end
        end
    }

    --Add the players.
    for _,MockPlayer in pairs(self.MockPlayers) do
        self.CuT:InitializePlayer(MockPlayer)
    end
end

--[[
Tests the GetAdminLevel method.
--]]
NexusUnitTesting:RegisterUnitTest(ServerAuthorizationUnitTest.new("GetAdminLevel"):SetRun(function(self)
    --Assert that the admin levels are correct.
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[1]),-1)
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[2]),3)
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[3]),-1)
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[4]),3)
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[5]),3)
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[6]),2)
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[7]),0)
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[8]),5)

    --Set an admin level and assert that it is correct.
    self.CuT:SetAdminLevel(self.MockPlayers[2],5)
    self:AssertEquals(self.CuT:GetAdminLevel(self.MockPlayers[2]),5)
end))



return true