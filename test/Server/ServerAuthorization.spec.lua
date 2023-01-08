--[[
TheNexusAvenger

Tests the ServerAuthorization class.
--]]
--!strict

local ServerAuthorization = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Server"):WaitForChild("ServerAuthorization"))
local Configuration = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Configuration"))

return function()
    local MockPlayers, TestServerAuthorization = nil, nil
    beforeEach(function()
        TestServerAuthorization = ServerAuthorization.new(Configuration.new({
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
        }), Instance.new("Folder"));
        (TestServerAuthorization :: any).GameId = 1
        (TestServerAuthorization :: any).CreatorId = 7

        MockPlayers = {
            {UserId = 1},
            {UserId = 2},
            {UserId = 3},
            {UserId = 4},
            {UserId = 5},
            {UserId = 6},
            {UserId = 25691148},
            {UserId = 7},
        } :: {any}

        (TestServerAuthorization :: any).GroupService = {
            GetGroupsAsync = function(self, Id)
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
        for _, MockPlayer in MockPlayers do
            (TestServerAuthorization :: any):InitializePlayer(MockPlayer)
        end
    end)

    describe("The authorization module on the server", function()
        it("should return correct admin levels.", function()
            --Assert that the admin levels are correct.
            expect(TestServerAuthorization:GetAdminLevel(MockPlayers[1])).to.equal(-1)
            expect(TestServerAuthorization:GetAdminLevel(MockPlayers[2])).to.equal(3)
            expect(TestServerAuthorization:GetAdminLevel(MockPlayers[3])).to.equal(-1)
            expect(TestServerAuthorization:GetAdminLevel(MockPlayers[4])).to.equal(3)
            expect(TestServerAuthorization:GetAdminLevel(MockPlayers[5])).to.equal(3)
            expect(TestServerAuthorization:GetAdminLevel(MockPlayers[6])).to.equal(2)
            expect(TestServerAuthorization:GetAdminLevel(MockPlayers[7])).to.equal(0)
            expect(TestServerAuthorization:GetAdminLevel(MockPlayers[8])).to.equal(5)

            --Set an admin level and assert that it is correct.
            TestServerAuthorization:SetAdminLevel(MockPlayers[2], 5)
            expect(TestServerAuthorization:GetAdminLevel(MockPlayers[2])).to.equal(5)
        end)
    end)
end