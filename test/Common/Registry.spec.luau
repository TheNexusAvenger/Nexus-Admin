--Tests the Registry class.

local Registry = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Registry"))

return function()
    describe("A Registry", function()
        local MockCommandContext = nil
        local TestNexusAdminRemotes = nil
        local TestRegistry = nil
        beforeEach(function()
            MockCommandContext = {
                Name = "print",
                Group = "Test",
                RawText = "print arg1 arg2",
                Executor = {UserId = 1},
                Arguments = {
                    {
                        GetValue = function()
                            return "arg1"
                        end
                    },
                    {
                        GetValue = function()
                            return "arg2"
                        end
                    },
                }
            }

            TestNexusAdminRemotes = Instance.new("Folder")
            TestRegistry = Registry.new({
                IsPlayerAuthorized = function(_,Player,Level)
                    return Player.UserId == 1
                end
            }, nil, nil, TestNexusAdminRemotes)
        end)

        local function expectDeepEquals(Expected: any, Actual: any)
            if typeof(Expected) == "table" and typeof(Actual) == "table" then
                for Key, Value in Expected do
                    expectDeepEquals(Value, Actual[Key])
                end
                return
            end
            expect(Expected).to.equal(Actual)
        end

        it("it should convert replicatable data with string keywords.", function()
            expectDeepEquals(TestRegistry:GetReplicatableCmdrData({
                Prefix = ":",
                Keyword = "test",
                AdminLevel = 2,
                Category = "Test Category",
            }), {
                Group = "Test Category",
                Args = {},
                Aliases = {},
                Name = "test",
                Description = "No description",
            })
        end)

        it("it should convert replicatable data with list of keywords.", function()
            expectDeepEquals(TestRegistry:GetReplicatableCmdrData({
                Prefix = ":",
                Keyword = {"test1","test2","test3"},
                AdminLevel = 2,
                Category = "Test Category",
            }), {
                Group = "Test Category",
                Args = {},
                Aliases = {"test2","test3"},
                Name = "test1",
                Description = "No description",
            })
        end)

        it("it should convert replicatable data with no category.", function()
            expectDeepEquals(TestRegistry:GetReplicatableCmdrData({
                Prefix = ":",
                Keyword = "test",
                AdminLevel = 2,
            }), {
                Group = "Ungrouped Commands",
                Args = {},
                Aliases = {},
                Name = "test",
                Description = "No description",
            })
        end)

        it("it should convert replicatable data with descriptions.", function()
            expectDeepEquals(TestRegistry:GetReplicatableCmdrData({
                Prefix = ":",
                Keyword = "test",
                AdminLevel = 2,
                Category = "Test Category",
                Description = "Test description",
            }), {
                Group = "Test Category",
                Args = {},
                Aliases = {},
                Name = "test",
                Description = "Test description",
            })

            expectDeepEquals(TestRegistry:GetReplicatableCmdrData({
                Prefix = ":",
                Keyword = "test",
                AdminLevel = 2,
                Category = "Test Category",
                ExtraInfo = "Test description",
            }), {
                Group = "Test Category",
                Args = {},
                Aliases = {},
                Name = "test",
                Description = "Test description",
            })
        end)

        it("it should convert replicatable data with arguments.", function()
            expectDeepEquals(TestRegistry:GetReplicatableCmdrData({
                Prefix = ":",
                Keyword = "test",
                AdminLevel = 2,
                Category = "Test Category",
                Args = {"test"},
            }), {
                Group = "Test Category",
                Args = {"test"},
                Aliases = {},
                Name = "test",
                Description = "No description",
            })

            expectDeepEquals(TestRegistry:GetReplicatableCmdrData({
                Prefix = ":",
                Keyword = "test",
                AdminLevel = 2,
                Category = "Test Category",
                Arguments = {"test"},
            }), {
                Group = "Test Category",
                Args = {"test"},
                Aliases = {},
                Name = "test",
                Description = "No description",
            })
        end)

        it("should perform BeforeRuns.", function()
            --Register a test command.
            TestRegistry:LoadCommand({
                Prefix = {":",";"},
                Keyword = "print",
                Group = "Test",
                AdminLevel = 2,
            })

            --Assert nothing is returned with a valid user.
            expect(TestRegistry:PerformBeforeRun(MockCommandContext),"Result was returned from valid BeforeRun.").to.equal(nil)

            --Assert a message is returned for unathorized cases.
            MockCommandContext.Executor.UserId = 2
            expect(TestRegistry:PerformBeforeRun(MockCommandContext)).to.equal("You are not authorized to run this command.","Message is incorrect.")
            MockCommandContext.Executor = nil :: any
            expect(TestRegistry:PerformBeforeRun(MockCommandContext)).to.equal("An executor is required if the admin level is defined.","Message is incorrect.")
        end)

        it("should create run methods with a Run field (V.2.0.0 and newer).", function()
            local RunCalled = false
            TestRegistry:CreateRunMethod({
                Keyword = "Test",
                Run = function(_,CommandContext)
                    RunCalled = true
                    expect(CommandContext).to.equal(MockCommandContext)
                end
            })(MockCommandContext)
            expect(RunCalled).to.equal(true)
        end)

        it("should create run methods with an OnCommandInvoked attribute (V.1.2.0 and older).", function()
            local OnInvokeCalled = false
            TestRegistry:CreateRunMethod({
                Keyword = "Test",
                OnCommandInvoked = function(Player, BaseMessage, ArgumentParser)
                    OnInvokeCalled = true
                    expect(MockCommandContext.Executor).to.equal(Player)
                    expect(BaseMessage).to.equal("print arg1 arg2")
                    expect(ArgumentParser:GetNextString()).to.equal("arg1")
                    expect(ArgumentParser:GetNextString()).to.equal("arg2")
                    expect(ArgumentParser:HasNext()).to.equal(false)
                end
            })(MockCommandContext)
            expect(OnInvokeCalled).to.equal(true)
        end)

        it("should create run methods with an OnCommandInvoked attribute with explicit arguments (V.1.0.1 and older).", function()
            local OnInvokeCalled = false
            TestRegistry:CreateRunMethod({
                Keyword = "Test",
                Arguments = {"String","String"},
                IgnoreFilter = true,
                OnCommandInvoked = function(Player, BaseMessage, Argument1, Argument2)
                    OnInvokeCalled = true
                    expect(Player).to.equal(MockCommandContext.Executor)
                    expect(BaseMessage).to.equal("print arg1 arg2")
                    expect(Argument1).to.equal("arg1")
                    expect(Argument2).to.equal("arg2")
                end
            })(MockCommandContext)
            expect(OnInvokeCalled).to.equal(true)
        end)

        it("should create run methods with an OnCommandInvoked attribute with not arguments (V.1.2.0 and older).", function()
            local OnInvokeCalled = false
            MockCommandContext.RawText = "print"
            TestRegistry:CreateRunMethod({
                Keyword = "Test",
                OnCommandInvoked = function(Player,BaseMessage,ArgumentParser)
                    OnInvokeCalled = true
                    expect(Player).to.equal(MockCommandContext.Executor)
                    expect(BaseMessage).to.equal("print")
                    expect(ArgumentParser:HasNext()).to.equal(false)
                end
            })(MockCommandContext)
            expect(OnInvokeCalled).to.equal(true)
        end)

        it("should add commands with 1 keyword.", function()
            TestRegistry:LoadCommand({
                Prefix = ":",
                Keyword = "test",
            })
            expectDeepEquals(TestRegistry.PrefixCommands, {[":test"] = "test"})
            expectDeepEquals(TestRegistry.Prefixes, {[":"] = true})
        end)

        it("should add commands with multiple keyword.", function()
            TestRegistry:LoadCommand({
                Prefix = ":",
                Keyword = {"test1", "test2", "test3"},
            })
            expectDeepEquals(TestRegistry.PrefixCommands, {[":test"] = "test", [":test1"] = "test1", [":test2"] = "test2", [":test3"] = "test3"})
            expectDeepEquals(TestRegistry.Prefixes, {[":"] = true})
        end)

        it("should add commands with no prefix.", function()
            TestRegistry:LoadCommand({
                Keyword = "test4",
            })
            expectDeepEquals(TestRegistry.PrefixCommands,{[":test"] = "test",[":test1"] = "test1",[":test2"] = "test2",[":test3"] = "test3"})
            expectDeepEquals(TestRegistry.Prefixes, {[":"] = true})
        end)

        it("should add commands with multiple prefixes.", function()
            TestRegistry:LoadCommand({
                Prefix = {":", ";"},
                Keyword = "test5",
            })
            expectDeepEquals(TestRegistry.PrefixCommands,{[":test"] = "test", [":test1"] = "test1", [":test2"] = "test2", [":test3"] = "test3", [":test5"] = "test5", [";test5"] = "test5"})
            expectDeepEquals(TestRegistry.Prefixes, {[":"] = true, [";"] = true})
        end)
    end)
end