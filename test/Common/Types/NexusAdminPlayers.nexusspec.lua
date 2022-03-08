--[[
TheNexusAvenger

Tests the NexusAdminPlayers type.
--]]

local NexusUnitTesting = require("NexusUnitTesting")
local NexusAdminPlayersUnitTest = NexusUnitTesting.UnitTest:Extend()

local NexusAdminPlayers = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Types"):WaitForChild("NexusAdminPlayers"))



--[[
Sets up the unit test.
--]]
function NexusAdminPlayersUnitTest:Setup()
    --Create the mock team.
    self.MockTeam = {
        Name = "TestTeam",
        GetPlayers = function()
            return {self.MockPlayers[1],self.MockPlayers[3]}
        end,
    }

    --Create the mock players.
    self.MockPlayers = {
        {
            Name = "Player1",
            UserId = 1,
        },
        {
            Name = "Player2",
            UserId = 2,
        },
        {
            Name = "Player3",
            UserId = 3,
        },
        {
            Name = "Player4",
            UserId = 4,
        },
    }

    --Create the mock API.
    self.MockAPI = {
        Types = {},
        Authorization = {
            IsPlayerAuthorized = function(_,Player)
                return Player == self.MockPlayers[1] or Player == self.MockPlayers[2]
            end,
        },
        Cmdr = {
            Registry = {
                RegisterType = function(_,_,Type)
                    self.CuT = Type
                end,
            },
            Util = {
                MakeFuzzyFinder = function(Input)
                    return function()
                        if Input[1] == self.MockTeam then
                            return {self.MockTeam}
                        else
                            return {self.MockPlayers[1],self.MockPlayers[2],self.MockPlayers[3]}
                        end
                    end
                end,
                GetNames = function(Input)
                    local Names = {}
                    for _,Ins in pairs(Input) do
                        table.insert(Names,Ins.Name)
                    end
                    return Names
                end,
            },
        },
    }

    --Create the mock Players.
    self.MockPlayersService = {
        GetPlayers = function()
            local PlayersClone = {}
            for _,Player in pairs(self.MockPlayers) do
                table.insert(PlayersClone,Player)
            end
            return PlayersClone
        end,
    }

    --Create the mock teams.
    self.MockTeamsService = {
        GetTeams = function()
            return {self.MockTeam}
        end
    }

    --Set up the component under testing.
    NexusAdminPlayers(self.MockAPI,self.MockPlayersService,self.MockTeamsService)
end

--[[
Tests the Validate method.
--]]
NexusUnitTesting:RegisterUnitTest(NexusAdminPlayersUnitTest.new("Validate"):SetRun(function(self)
    --Tests the results for players.
    local Valid,Message = self.CuT.Validate(self.CuT.Transform("player1",self.MockPlayers[1]))
    self:AssertTrue(Valid,"Search isn't valid.")
    self:AssertEquals(Message,"No players were found matching that query.","Message is incorrect.")

    --Tests the results for teams.
    local Valid,Message = self.CuT.Validate(self.CuT.Transform("%test",self.MockPlayers[1]))
    self:AssertTrue(Valid,"Search isn't valid.")
    self:AssertEquals(Message,"No teams were found matching that query.","Message is incorrect.")
end))

--[[
Tests the Autocomplete method.
--]]
NexusUnitTesting:RegisterUnitTest(NexusAdminPlayersUnitTest.new("Autocomplete"):SetRun(function(self)
    --Test the shorthands.
    self:AssertEquals(self.CuT.Autocomplete(self.CuT.Transform(".",self.MockPlayers[1])),{"Player1"})
    self:AssertEquals(self.CuT.Autocomplete(self.CuT.Transform("me",self.MockPlayers[1])),{"Player1"})
    self:AssertEquals(self.CuT.Autocomplete(self.CuT.Transform("*",self.MockPlayers[1])),{"Player1","Player2","Player3","Player4"})
    self:AssertEquals(self.CuT.Autocomplete(self.CuT.Transform("all",self.MockPlayers[1])),{"Player1","Player2","Player3","Player4"})
    self:AssertEquals(self.CuT.Autocomplete(self.CuT.Transform("others",self.MockPlayers[1])),{"Player2","Player3","Player4"})
    self:AssertEquals(self.CuT.Autocomplete(self.CuT.Transform("admins",self.MockPlayers[1])),{"Player1","Player2"})
    self:AssertEquals(self.CuT.Autocomplete(self.CuT.Transform("nonadmins",self.MockPlayers[1])),{"Player3","Player4"})
    self:AssertEquals(#self.CuT.Autocomplete(self.CuT.Transform("random",self.MockPlayers[1])),1)
    self:AssertEquals(#self.CuT.Autocomplete(self.CuT.Transform("?",self.MockPlayers[1])),1)
    self:AssertEquals(#self.CuT.Autocomplete(self.CuT.Transform("?3",self.MockPlayers[1])),3)
    self:AssertEquals(#self.CuT.Autocomplete(self.CuT.Transform("?6",self.MockPlayers[1])),4)
    
    --Test the players.
    self:AssertEquals(self.CuT.Autocomplete(self.CuT.Transform("someName",self.MockPlayers[1])),{"Player1","Player2","Player3"})

    --Test the teams.
    self:AssertEquals(self.CuT.Autocomplete(self.CuT.Transform("%test",self.MockPlayers[1])),{"%TestTeam"})
end))

--[[
Tests the Parse method.
--]]
NexusUnitTesting:RegisterUnitTest(NexusAdminPlayersUnitTest.new("Parse"):SetRun(function(self)
    --Test the shorthands.
    self:AssertEquals(self.CuT.Parse(self.CuT.Transform(".",self.MockPlayers[1])),{self.MockPlayers[1]})
    self:AssertEquals(self.CuT.Parse(self.CuT.Transform("me",self.MockPlayers[1])),{self.MockPlayers[1]})
    self:AssertEquals(self.CuT.Parse(self.CuT.Transform("*",self.MockPlayers[1])),{self.MockPlayers[1],self.MockPlayers[2],self.MockPlayers[3],self.MockPlayers[4]})
    self:AssertEquals(self.CuT.Parse(self.CuT.Transform("all",self.MockPlayers[1])),{self.MockPlayers[1],self.MockPlayers[2],self.MockPlayers[3],self.MockPlayers[4]})
    self:AssertEquals(self.CuT.Parse(self.CuT.Transform("others",self.MockPlayers[1])),{self.MockPlayers[2],self.MockPlayers[3],self.MockPlayers[4]})
    self:AssertEquals(self.CuT.Parse(self.CuT.Transform("admins",self.MockPlayers[1])),{self.MockPlayers[1],self.MockPlayers[2]})
    self:AssertEquals(self.CuT.Parse(self.CuT.Transform("nonadmins",self.MockPlayers[1])),{self.MockPlayers[3],self.MockPlayers[4]})
    self:AssertEquals(#self.CuT.Parse(self.CuT.Transform("random",self.MockPlayers[1])),1)
    self:AssertEquals(#self.CuT.Parse(self.CuT.Transform("?",self.MockPlayers[1])),1)
    self:AssertEquals(#self.CuT.Parse(self.CuT.Transform("?3",self.MockPlayers[1])),3)
    self:AssertEquals(#self.CuT.Parse(self.CuT.Transform("?6",self.MockPlayers[1])),4)
    
    --Test the players.
    self:AssertEquals(self.CuT.Parse(self.CuT.Transform("someName",self.MockPlayers[1])),{self.MockPlayers[1],self.MockPlayers[2],self.MockPlayers[3]})

    --Test the teams.
    self:AssertEquals(self.CuT.Parse(self.CuT.Transform("%test",self.MockPlayers[1])),{self.MockPlayers[1],self.MockPlayers[3]})
end))

--[[
Tests the Parse method with players.
--]]
NexusUnitTesting:RegisterUnitTest(NexusAdminPlayersUnitTest.new("ParseFilter"):SetRun(function(self)
    self:AssertEquals(self.CuT.Parse(self.CuT.Transform("all[me]", self.MockPlayers[1])), {self.MockPlayers[1]})
    self:AssertEquals(#self.CuT.Parse(self.CuT.Transform("others[?6]", self.MockPlayers[1])), 3)
    self:AssertEquals(self.CuT.Parse(self.CuT.Transform("others[%test]", self.MockPlayers[1])), {self.MockPlayers[3]})
    self:AssertEquals(self.CuT.Parse(self.CuT.Transform("%test[others]", self.MockPlayers[1])), {self.MockPlayers[3]})
end))



return true