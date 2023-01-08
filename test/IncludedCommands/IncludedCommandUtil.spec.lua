--[[
TheNexusAvenger

Tests the IncludedCommandUtil class.
--]]
--!strict

local IncludedCommandUtil = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("IncludedCommands"):WaitForChild("IncludedCommandUtil"))

return function()
    describe("A static util", function()
        it("should get remaining strings.", function()
            --Assert normal strings are valid.
            expect(IncludedCommandUtil:GetRemainingString("Test1 Test2 Test3", 1)).to.equal("Test2 Test3")
            expect(IncludedCommandUtil:GetRemainingString("Test1 Test2 Test3", 2)).to.equal("Test3")

            --Assert strings with extra spaces are valid.
            expect(IncludedCommandUtil:GetRemainingString("   Test1 Test2 Test3", 1)).to.equal("Test2 Test3")
            expect(IncludedCommandUtil:GetRemainingString("   Test1 Test2 Test3", 2)).to.equal("Test3")
            expect(IncludedCommandUtil:GetRemainingString(" Test1 Test2 Test3", 1)).to.equal("Test2 Test3")
            expect(IncludedCommandUtil:GetRemainingString(" Test1 Test2 Test3", 2)).to.equal("Test3")
            expect(IncludedCommandUtil:GetRemainingString("Test1   Test2   Test3", 1)).to.equal("Test2   Test3")
            expect(IncludedCommandUtil:GetRemainingString("Test1   Test2   Test3", 2)).to.equal("Test3")
            
            --Assert strings with quotes.
            expect(IncludedCommandUtil:GetRemainingString("\"Test 1\" \"Test 2\" \"Test 3\"", 1)).to.equal("\"Test 2\" \"Test 3\"")
            expect(IncludedCommandUtil:GetRemainingString("\"Test 1\" \"Test 2\" \"Test 3\"", 2)).to.equal("\"Test 3\"")

            --Assert empty cases return.
            expect(IncludedCommandUtil:GetRemainingString("Test1 Test2 Test3", 3)).to.equal("")
            expect(IncludedCommandUtil:GetRemainingString("Test1 Test2 Test3", 4)).to.equal("")
            expect(IncludedCommandUtil:GetRemainingString("Test1 Test2 Test3", 0)).to.equal("Test1 Test2 Test3")
        end)
    end)
end