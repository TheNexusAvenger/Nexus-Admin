--[[
TheNexusAvenger

Tests the Authorization class.
--]]
--!strict

local Authorization = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Authorization"))
local Configuration = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Configuration"))

return function()
    local TestAuthorization, MockPlayers = nil, nil
    beforeEach(function()
        TestAuthorization = Authorization.new(Configuration.new({}))

        --Create the mock players.
        MockPlayers = {
            {UserId=1},
            {UserId=2},
            {UserId=3},
        } :: {any}

        --Initialize some admin levels admin levels.
        TestAuthorization:SetAdminLevel(MockPlayers[1], -1)
        TestAuthorization:SetAdminLevel(MockPlayers[2], 4)
    end)

    describe("The authorization module", function()
        it("should return correct admin levels.", function()
            --Assert that the admin levels are correct.
            expect(TestAuthorization:GetAdminLevel(MockPlayers[1])).to.equal(-1)
            expect(TestAuthorization:GetAdminLevel(MockPlayers[2])).to.equal(4)
            expect(TestAuthorization:GetAdminLevel(MockPlayers[3])).to.equal(-1)

            --Set an admin level and assert that it is correct.
            TestAuthorization:SetAdminLevel(MockPlayers[2], 5)
            expect(TestAuthorization:GetAdminLevel(MockPlayers[2])).to.equal(5)
        end)

        it("should show players as correctly authorized.", function()
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[1], -1)).to.equal(true)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[1], 0)).to.equal(false)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[1], 1)).to.equal(false)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[1], 2)).to.equal(false)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[1], 3)).to.equal(false)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[1], 4)).to.equal(false)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[1], 5)).to.equal(false)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[2], -1)).to.equal(true)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[2], 0)).to.equal(true)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[2], 1)).to.equal(true)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[2], 2)).to.equal(true)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[2], 3)).to.equal(true)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[2], 4)).to.equal(true)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[2], 5)).to.equal(false)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[3], -1)).to.equal(true)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[3], 0)).to.equal(false)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[3], 1)).to.equal(false)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[3], 2)).to.equal(false)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[3], 3)).to.equal(false)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[3], 4)).to.equal(false)
            expect(TestAuthorization:IsPlayerAuthorized(MockPlayers[3], 5)).to.equal(false)
        end)

        it("should wait for admin levels.", function()
            --Assert there is no yielding for existing admins.
            expect(TestAuthorization:YieldForAdminLevel(MockPlayers[1])).to.equal(-1)
            expect(TestAuthorization:YieldForAdminLevel(MockPlayers[2])).to.equal(4)

            --Yield for an admin level and assert it continues.
            task.spawn(function()
                TestAuthorization:SetAdminLevel(MockPlayers[3], 5)
            end)
            expect(TestAuthorization:YieldForAdminLevel(MockPlayers[3])).to.equal(5)
        end)
    end)
end