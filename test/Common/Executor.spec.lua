--[[
TheNexusAvenger

Tests the Executor class.
--]]
--!strict

local Executor = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Executor"))

return function()
    local MockCmdr, MockRegistry, TestExecutor = nil, nil, nil
    beforeEach(function()
        MockCmdr = {
            Dispatcher = {
                EvaluateAndRun = function(self,Command)
                    self.LastCommand = Command
                    return "Mock success."
                end,
            }
        } :: any
        MockRegistry = {
            PrefixCommands = {
                [":m"] = "m",
                [":cmds"] = "cmds",
                ["!cmds"] = "cmds",
            }
        }
        TestExecutor = Executor.new(MockCmdr :: any, MockRegistry :: any)
    end)

    describe("The executor module", function()
        it("should unescape strings.", function()
            expect(TestExecutor:Unescape("test")).to.equal("test")
            expect(TestExecutor:Unescape("test\\test")).to.equal("testtest")
            expect(TestExecutor:Unescape("test\\\\test")).to.equal("test\\test")
            expect(TestExecutor:Unescape("\"test\"")).to.equal("test")
            expect(TestExecutor:Unescape("\"test\"test\"test\"")).to.equal("testtesttest")
            expect(TestExecutor:Unescape("test\\\\\"test")).to.equal("test\\test")
            expect(TestExecutor:Unescape("test\\\\\\\"test")).to.equal("test\\\"test")
        end)
        
        it("should execute commands with prefixes.", function()
            expect(TestExecutor:ExecuteCommandWithPrefix(":m Test")).to.equal("Mock success.")
            expect(MockCmdr.Dispatcher.LastCommand).to.equal("m Test")
            expect(TestExecutor:ExecuteCommandWithPrefix(":M Test")).to.equal("Mock success.")
            expect(MockCmdr.Dispatcher.LastCommand).to.equal("m Test")
            expect(TestExecutor:ExecuteCommandWithPrefix(":cmds")).to.equal("Mock success.")
            expect(MockCmdr.Dispatcher.LastCommand).to.equal("cmds")
            expect(TestExecutor:ExecuteCommandWithPrefix("!cmds")).to.equal("Mock success.")
            expect(MockCmdr.Dispatcher.LastCommand).to.equal("cmds")
            expect(TestExecutor:ExecuteCommandWithPrefix(":CmdS")).to.equal("Mock success.")
            expect(MockCmdr.Dispatcher.LastCommand).to.equal("cmds")
            expect(TestExecutor:ExecuteCommandWithPrefix("!CMDS")).to.equal("Mock success.")
            expect(MockCmdr.Dispatcher.LastCommand).to.equal("cmds")
            expect(TestExecutor:ExecuteCommandWithPrefix(";cmds")).to.equal("Unknown command.")
            expect(TestExecutor:ExecuteCommandWithPrefix(":test")).to.equal("Unknown command.")
        end)

        it("should split commands.", function()
            local function expectTableEqual(Table1, Table2)
                for i = 1, math.max(#Table1, #Table2) do
                    expect(Table1[i]).to.equal(Table2[i])
                end
            end

            --Assert no splitting.
            expectTableEqual(TestExecutor:SplitCommands("", "/"), {""})
            expectTableEqual(TestExecutor:SplitCommands("test", "/"), {"test"})
            expectTableEqual(TestExecutor:SplitCommands("test\\test", "/"), {"testtest"})

            --Assert basic splitting.
            expectTableEqual(TestExecutor:SplitCommands("//", "/"), {"", "", ""})
            expectTableEqual(TestExecutor:SplitCommands("test/test/test", "/"), {"test", "test", "test"})

            --Assert whitespace trimming.
            expectTableEqual(TestExecutor:SplitCommands("  test  /  test/  test  ", "/"), {"test", "test", "test"})

            --Assert quotes with splitting.
            expectTableEqual(TestExecutor:SplitCommands("test\"/\"test", "/"), {"test/test"})
            expectTableEqual(TestExecutor:SplitCommands("test\"/test\"", "/"), {"test/test"})
            expectTableEqual(TestExecutor:SplitCommands("\"test/\"test", "/"), {"test/test"})
            expectTableEqual(TestExecutor:SplitCommands("\"test/test\"", "/"), {"test/test"})
            expectTableEqual(TestExecutor:SplitCommands("\"", "/"), {""})
        end)
    end)
end