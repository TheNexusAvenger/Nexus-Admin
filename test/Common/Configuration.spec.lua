--[[
TheNexusAvenger

Tests the Configuration class.
--]]
--!strict

local Configuration = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Configuration"))

return function()
    local TestConfiguration = nil
    beforeEach(function()
        TestConfiguration = Configuration.new({
            BuildUtilityLevel = 3,
            CommandLevelOverrides = {
                BuildUtility = {
                    clearterrain = 4,
                    s = 5,
                    insert = nil,
                },
            }
        })
    end)

    describe("The configuration module", function()
        it("should return correct command level.", function()
            --Test the default admin levels.
            expect(TestConfiguration:GetCommandAdminLevel("Administrative", "unknown_command")).to.equal(1)
            expect(TestConfiguration:GetCommandAdminLevel("BasicCommands", "unknown_command")).to.equal(1)
            expect(TestConfiguration:GetCommandAdminLevel("UsefulFunCommands", "unknown_command")).to.equal(2)
            expect(TestConfiguration:GetCommandAdminLevel("FunCommands", "unknown_command")).to.equal(3)
            expect(TestConfiguration:GetCommandAdminLevel("PersistentCommands", "unknown_command")).to.equal(4)

            --Test the overriden admin levels.
            expect(TestConfiguration:GetCommandAdminLevel("BuildUtility", "unknown_command")).to.equal(3)
            expect(TestConfiguration:GetCommandAdminLevel("BuildUtility", "clearterrain")).to.equal(4)
            expect(TestConfiguration:GetCommandAdminLevel("BuildUtility", "s")).to.equal(5)
            expect(TestConfiguration:GetCommandAdminLevel("BuildUtility", "insert")).to.equal(3)

            --Test a missing category.
            expect(function()
                TestConfiguration:GetCommandAdminLevel("UnknownCategory", "unknown_command")
            end).to.throw()
        end)
    end)
end