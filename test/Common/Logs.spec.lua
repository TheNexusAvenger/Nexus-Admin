--[[
TheNexusAvenger

Tests the Logs class.
--]]
--!strict

local Logs = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Logs"))

return function()
    local TestLogs = nil
    beforeEach(function()
        TestLogs = Logs.new(3)
    end)
    afterEach(function()
        TestLogs:Destroy()
    end)

    describe("A logs instance", function()
        it("should add logs.", function()
            local function expectTableEqual(Table1, Table2)
                for i = 1, math.max(#Table1, #Table2) do
                    expect(Table1[i]).to.equal(Table2[i])
                end
            end

            local LogAddedEvents = {}
            TestLogs.LogAdded:Connect(function(Log)
                table.insert(LogAddedEvents, Log)
            end)

            TestLogs:Add("Log 1")
            expectTableEqual(TestLogs:GetLogs(), {"Log 1"})
            TestLogs:Add("Log 2")
            expectTableEqual(TestLogs:GetLogs(), {"Log 2", "Log 1"})
            TestLogs:Add("Log 3")
            expectTableEqual(TestLogs:GetLogs(), {"Log 3", "Log 2", "Log 1"})
            TestLogs:Add("Log 4")
            expectTableEqual(TestLogs:GetLogs(), {"Log 4", "Log 3", "Log 2"})
            task.wait()
            expectTableEqual(LogAddedEvents, {"Log 1", "Log 2", "Log 3", "Log 4"})
        end)
    end)
end