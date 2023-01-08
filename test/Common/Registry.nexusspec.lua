--[[
TheNexusAvenger

Tests the Registry class.
--]]
--TODO: Convert to 

local NexusUnitTesting = require("NexusUnitTesting")
local RegistryUnitTest = NexusUnitTesting.UnitTest:Extend()

local Registry = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Registry"))



--[[
Sets up the unit test.
--]]
function RegistryUnitTest:Setup()
    --Create the component under testing.
    self.NexusAdminRemotes = Instance.new("Folder")
    self.CuT = Registry.new({
        IsPlayerAuthorized = function(_,Player,Level)
            return Player.UserId == 1
        end
    }, nil, nil, self.NexusAdminRemotes)
end

--[[
Tests the GetReplicatableCmdrData method.
--]]
NexusUnitTesting:RegisterUnitTest(RegistryUnitTest.new("GetReplicatableCmdrData"):SetRun(function(self)
    --Test with the keyword being a string.
    self:AssertEquals(self.CuT:GetReplicatableCmdrData({
        Prefix = ":",
        Keyword = "test",
        AdminLevel = 2,
        Category = "Test Category",
    }),{
        Group = "Test Category",
        Args = {},
        Aliases = {},
        Name = "test",
        Description = "No description",
    })

    --Test with the keyword being a list.
    self:AssertEquals(self.CuT:GetReplicatableCmdrData({
        Prefix = ":",
        Keyword = {"test1","test2","test3"},
        AdminLevel = 2,
        Category = "Test Category",
    }),{
        Group = "Test Category",
        Args = {},
        Aliases = {"test2","test3"},
        Name = "test1",
        Description = "No description",
    })

    --Tests with no category being defined.
    self:AssertEquals(self.CuT:GetReplicatableCmdrData({
        Prefix = ":",
        Keyword = "test",
        AdminLevel = 2,
    }),{
        Group = "Ungrouped Commands",
        Args = {},
        Aliases = {},
        Name = "test",
        Description = "No description",
    })

    --Test with a description.
    self:AssertEquals(self.CuT:GetReplicatableCmdrData({
        Prefix = ":",
        Keyword = "test",
        AdminLevel = 2,
        Category = "Test Category",
        Description = "Test description",
    }),{
        Group = "Test Category",
        Args = {},
        Aliases = {},
        Name = "test",
        Description = "Test description",
    })
    self:AssertEquals(self.CuT:GetReplicatableCmdrData({
        Prefix = ":",
        Keyword = "test",
        AdminLevel = 2,
        Category = "Test Category",
        ExtraInfo = "Test description",
    }),{
        Group = "Test Category",
        Args = {},
        Aliases = {},
        Name = "test",
        Description = "Test description",
    })

    --Test with the arguments.
    self:AssertEquals(self.CuT:GetReplicatableCmdrData({
        Prefix = ":",
        Keyword = "test",
        AdminLevel = 2,
        Category = "Test Category",
        Args = {"test"},
    }),{
        Group = "Test Category",
        Args = {"test"},
        Aliases = {},
        Name = "test",
        Description = "No description",
    })
    self:AssertEquals(self.CuT:GetReplicatableCmdrData({
        Prefix = ":",
        Keyword = "test",
        AdminLevel = 2,
        Category = "Test Category",
        Arguments = {"test"},
    }),{
        Group = "Test Category",
        Args = {"test"},
        Aliases = {},
        Name = "test",
        Description = "No description",
    })
end))

--[[
Tests the PerformBeforeRun method.
--]]
NexusUnitTesting:RegisterUnitTest(RegistryUnitTest.new("PerformBeforeRun"):SetRun(function(self)
    --Create a mock command context.
    local MockCommandContext = {
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

    --Register a test command.
    self.CuT:LoadCommand({
        Prefix = {":",";"},
        Keyword = "print",
        Group = "Test",
        AdminLevel = 2,
    })

    --Assert nothing is returned with a valid user.
    self:AssertNil(self.CuT:PerformBeforeRun(MockCommandContext),"Result was returned from valid BeforeRun.")

    --Assert a message is returned for unathorized cases.
    MockCommandContext.Executor.UserId = 2
    self:AssertEquals(self.CuT:PerformBeforeRun(MockCommandContext),"You are not authorized to run this command.","Message is incorrect.")
    MockCommandContext.Executor = nil
    self:AssertEquals(self.CuT:PerformBeforeRun(MockCommandContext),"An executor is required if the admin level is defined.","Message is incorrect.")
end))

--[[
Tests the CreateRunMethod method.
--]]
NexusUnitTesting:RegisterUnitTest(RegistryUnitTest.new("CreateRunMethod"):SetRun(function(self)
    --Create a mock command context.
    local MockCommandContext = {
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

    --Tests with a Run attribute (V.2.0.0 and newer).
    local RunCalled = false
    self.CuT:CreateRunMethod({
        Keyword = "Test",
        Run = function(_,CommandContext)
            RunCalled = true
            self:AssertSame(CommandContext,MockCommandContext,"Command context not the same.")
        end
    })(MockCommandContext)
    self:AssertTrue(RunCalled,"Run function not called.")

    --Tests with a OnCommandInvoked attribute (V.1.2.0 and older).
    local OnInvokeCalled = false
    self.CuT:CreateRunMethod({
        Keyword = "Test",
        OnCommandInvoked = function(Player,BaseMessage,ArgumentParser)
            OnInvokeCalled = true
            self:AssertEquals(Player,MockCommandContext.Executor,"Player is incorrect.")
            self:AssertEquals(BaseMessage,"print arg1 arg2","Message is incorrect.")
            self:AssertEquals(ArgumentParser:GetNextString(),"arg1","Argument is incorrect.")
            self:AssertEquals(ArgumentParser:GetNextString(),"arg2","Argument is incorrect.")
            self:AssertFalse(ArgumentParser:HasNext(),"Next value exists.")
        end
    })(MockCommandContext)
    self:AssertTrue(OnInvokeCalled,"OnCommandInvoked function not called.")

    --Tests with a OnCommandInvoked attribute with explicit arguments (V.1.0.1 and older).
    OnInvokeCalled = false
    self.CuT:CreateRunMethod({
        Keyword = "Test",
        Arguments = {"String","String"},
        IgnoreFilter = true,
        OnCommandInvoked = function(Player,BaseMessage,Argument1,Argument2)
            OnInvokeCalled = true
            self:AssertEquals(Player,MockCommandContext.Executor,"Player is incorrect.")
            self:AssertEquals(BaseMessage,"print arg1 arg2","Message is incorrect.")
            self:AssertEquals(Argument1,"arg1","Argument 1 is incorrect.")
            self:AssertEquals(Argument2,"arg2","Argument 2 is incorrect.")
        end
    })(MockCommandContext)
    self:AssertTrue(OnInvokeCalled,"OnCommandInvoked function not called.")

    --Tests with a OnCommandInvoked attribute with no arguments (V.1.2.0 and older).
    OnInvokeCalled = false
    MockCommandContext.RawText = "print"
    self.CuT:CreateRunMethod({
        Keyword = "Test",
        OnCommandInvoked = function(Player,BaseMessage,ArgumentParser)
            OnInvokeCalled = true
            self:AssertEquals(Player,MockCommandContext.Executor,"Player is incorrect.")
            self:AssertEquals(BaseMessage,"print","Message is incorrect.")
            self:AssertFalse(ArgumentParser:HasNext(),"Next value exists.")
        end
    })(MockCommandContext)
    self:AssertTrue(OnInvokeCalled,"OnCommandInvoked function not called.")
end))

--[[
Tests the LoadCommand method.
--]]
NexusUnitTesting:RegisterUnitTest(RegistryUnitTest.new("LoadCommand"):SetRun(function(self)
    --Add a command with 1 keyword and assert the prefixes are correct.
    self.CuT:LoadCommand({
        Prefix = ":",
        Keyword = "test",
    })
    self:AssertEquals(self.CuT.PrefixCommands,{[":test"] = "test"})
    self:AssertEquals(self.CuT.Prefixes,{[":"] = true})

    --Add a command with many keywords and assert the prefixes are correct.
    self.CuT:LoadCommand({
        Prefix = ":",
        Keyword = {"test1","test2","test3"},
    })
    self:AssertEquals(self.CuT.PrefixCommands,{[":test"] = "test",[":test1"] = "test1",[":test2"] = "test2",[":test3"] = "test3"})
    self:AssertEquals(self.CuT.Prefixes,{[":"] = true})

    --Add a command without a prefix and assert the prefixes are correct.
    self.CuT:LoadCommand({
        Keyword = "test4",
    })
    self:AssertEquals(self.CuT.PrefixCommands,{[":test"] = "test",[":test1"] = "test1",[":test2"] = "test2",[":test3"] = "test3"})
    self:AssertEquals(self.CuT.Prefixes,{[":"] = true})

    --Add a command with 1 keyword and multiple prefixes and assert the prefixes are correct.
    self.CuT:LoadCommand({
        Prefix = {":",";"},
        Keyword = "test5",
    })
    self:AssertEquals(self.CuT.PrefixCommands,{[":test"] = "test",[":test1"] = "test1",[":test2"] = "test2",[":test3"] = "test3",[":test5"] = "test5",[";test5"] = "test5"})
    self:AssertEquals(self.CuT.Prefixes,{[":"] = true,[";"] = true})
end))



return true