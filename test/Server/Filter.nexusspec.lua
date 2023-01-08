--[[
TheNexusAvenger

Tests the Filter class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local FilterUnitTest = NexusUnitTesting.UnitTest:Extend()

local Filter = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Server"):WaitForChild("Filter"))



--[[
Sets up the unit test.
--]]
function FilterUnitTest:Setup()
    --Create the component under testing.
    self.CuT = Filter.new()

    --Create the mock players.
    self.MockPlayers = {
        {UserId=1},
        {UserId=2},
        {UserId=3},
    }

    --Mock the TextServuce.
    self.CuT.TextService = {
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

    --Mock the chat.
    self.CuT.Chat = {
        CanUsersChatAsync = function(_,Player1,Player2)
            return Player1 ~= 2 or Player2 ~= 3
        end,
    }
end

--[[
Tests the FilterStringForPlayers method.
--]]
NexusUnitTesting:RegisterUnitTest(FilterUnitTest.new("FilterStringForPlayers"):SetRun(function(self)
    self:AssertEquals(self.CuT:FilterStringForPlayers("     ",self.MockPlayers[1],{self.MockPlayers[1],self.MockPlayers[2]}),{[self.MockPlayers[1]] = "     ",[self.MockPlayers[2]] = "     "})
    self:AssertEquals(self.CuT:FilterStringForPlayers("FailMessage",self.MockPlayers[1],{self.MockPlayers[1],self.MockPlayers[2]}),{[self.MockPlayers[1]] = "###########",[self.MockPlayers[2]] = "###########"})
    self:AssertEquals(self.CuT:FilterStringForPlayers("Test message",self.MockPlayers[1],{self.MockPlayers[1],self.MockPlayers[2]}),{[self.MockPlayers[1]] = "#### message",[self.MockPlayers[2]] = "Test message"})
    self:AssertEquals(self.CuT:FilterStringForPlayers("Test message",self.MockPlayers[2],{self.MockPlayers[1],self.MockPlayers[3]}),{[self.MockPlayers[1]] = "#### message",[self.MockPlayers[3]] = "(Your chat settings prevent you from seeing messages)"})
end))



return true