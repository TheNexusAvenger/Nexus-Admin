--[[
TheNexusAvenger

Tests the Filter class.
--]]
--!strict

local Filter = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Server"):WaitForChild("Filter"))

return function()
    local MockPlayers, TestFilter = nil, nil
    beforeEach(function()
        TestFilter = Filter.new()

        MockPlayers = {
            {UserId=1},
            {UserId=2},
            {UserId=3},
        } :: {any}

        (TestFilter :: any).TextService = {
            FilterStringAsync = function(_,String)
                if String == "FailMessage" then
                    error("Test error")
                else
                    return {
                        GetChatForUserAsync = function(_,Id)
                            if Id == 1 then
                                return "#### message"
                            else
                                return "Test message"
                            end
                        end,
                        GetNonChatStringForBroadcastAsync = function()
                            return "Test #######"
                        end,
                    }
                end
            end
        }
    
        (TestFilter :: any).Chat = {
            CanUsersChatAsync = function(_,Player1,Player2)
                return Player1 ~= 2 or Player2 ~= 3
            end,
        }
    end)

    describe("The filter module", function()
        it("should filter strings.", function()
            expect(TestFilter:FilterString("     ", MockPlayers[1])).to.equal("     ")
            expect(TestFilter:FilterString("FailMessage", MockPlayers[1])).to.equal("###########")
            expect(TestFilter:FilterString("Test message", MockPlayers[1])).to.equal("Test #######")
            expect(TestFilter:FilterString("Test message", MockPlayers[1], MockPlayers[2])).to.equal("Test message")
            expect(TestFilter:FilterString("Test message", MockPlayers[2], MockPlayers[3])).to.equal("(Your chat settings prevent you from seeing messages)")
        end)

        it("should filter strings for players.", function()
            local FilterResults = TestFilter:FilterStringForPlayers("     ", MockPlayers[1], {MockPlayers[1], MockPlayers[2]})
            expect(FilterResults[MockPlayers[1]]).to.equal("     ")
            expect(FilterResults[MockPlayers[2]]).to.equal("     ")

            FilterResults = TestFilter:FilterStringForPlayers("FailMessage", MockPlayers[1], {MockPlayers[1], MockPlayers[2]})
            expect(FilterResults[MockPlayers[1]]).to.equal("###########")
            expect(FilterResults[MockPlayers[2]]).to.equal("###########")

            FilterResults = TestFilter:FilterStringForPlayers("Test message", MockPlayers[1], {MockPlayers[1], MockPlayers[2]})
            expect(FilterResults[MockPlayers[1]]).to.equal("#### message")
            expect(FilterResults[MockPlayers[2]]).to.equal("Test message")

            FilterResults = TestFilter:FilterStringForPlayers("Test message", MockPlayers[2], {MockPlayers[1], MockPlayers[3]})
            expect(FilterResults[MockPlayers[1]]).to.equal("#### message")
            expect(FilterResults[MockPlayers[3]]).to.equal("(Your chat settings prevent you from seeing messages)")
        end)
    end)
end