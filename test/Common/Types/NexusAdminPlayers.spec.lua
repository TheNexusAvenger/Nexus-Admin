--[[
TheNexusAvenger

Tests the NexusAdminPlayers type.
--]]
--!strict

local NexusAdminPlayers = require(game:GetService("ServerScriptService"):WaitForChild("MainModule"):WaitForChild("NexusAdmin"):WaitForChild("Common"):WaitForChild("Types"):WaitForChild("NexusAdminPlayers"))

return function()
    local MockTeam, MockPlayers, MockPlayersService, MockTeamsService, MockAPI, TestNexusAdminPlayers = nil, nil, nil, nil, nil, nil
    beforeEach(function()
        --Create the mock team.
        MockTeam = {
            Name = "TestTeam",
            GetPlayers = function()
                return {MockPlayers[1], MockPlayers[3]}
            end,
        }

        --Create the mock players.
        MockPlayers = {
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
        MockAPI = {
            Types = {},
            Authorization = {
                IsPlayerAuthorized = function(_, Player)
                    return Player == MockPlayers[1] or Player == MockPlayers[2]
                end,
            },
            Cmdr = {
                Registry = {
                    RegisterType = function(_, _, Type)
                        TestNexusAdminPlayers = Type
                    end,
                },
                Util = {
                    MakeFuzzyFinder = function(Input)
                        return function(): {any}
                            if Input[1] == MockTeam then
                                return {MockTeam}
                            else
                                return {MockPlayers[1], MockPlayers[2], MockPlayers[3]}
                            end
                        end
                    end,
                    GetNames = function(Input)
                        local Names = {}
                        for _,Ins in Input do
                            table.insert(Names, Ins.Name)
                        end
                        return Names
                    end,
                },
            },
        }

        --Create the mock Players.
        MockPlayersService = {
            GetPlayers = function()
                local PlayersClone = {}
                for _, Player in MockPlayers do
                    table.insert(PlayersClone, Player)
                end
                return PlayersClone
            end,
        }

        --Create the mock teams.
        MockTeamsService = {
            GetTeams = function()
                return {MockTeam}
            end
        }

        --Set up the component under testing.
        NexusAdminPlayers(MockAPI :: any, MockPlayersService :: any, MockTeamsService :: any)
    end)

    describe("Nexus admin players", function()
        it("should validate inputs.", function()
            --Tests the results for players.
            local Valid, Message = TestNexusAdminPlayers.Validate(TestNexusAdminPlayers.Transform("player1", MockPlayers[1]))
            expect(Valid).to.equal(true)
            expect(Message).to.equal("No players were found matching that query.")

            --Tests the results for teams.
            Valid, Message = TestNexusAdminPlayers.Validate(TestNexusAdminPlayers.Transform("%test", MockPlayers[1]))
            expect(Valid).to.equal(true)
            expect(Message).to.equal("No teams were found matching that query.")
        end)

        it("should autocomplete players.", function()
            local function expectTableEqual(Table1, Table2)
                for i = 1, math.max(#Table1, #Table2) do
                    expect(Table1[i]).to.equal(Table2[i])
                end
            end

            --Test the shorthands.
            expectTableEqual(TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("", MockPlayers[1])), {"Player1", "Player2", "Player3"})
            expectTableEqual(TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform(".", MockPlayers[1])), {"Player1"})
            expectTableEqual(TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("me", MockPlayers[1])), {"Player1"})
            expectTableEqual(TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("*", MockPlayers[1])), {"Player1", "Player2", "Player3", "Player4"})
            expectTableEqual(TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("all", MockPlayers[1])), {"Player1", "Player2", "Player3", "Player4"})
            expectTableEqual(TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("others", MockPlayers[1])), {"Player2", "Player3", "Player4"})
            expectTableEqual(TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("admins", MockPlayers[1])), {"Player1", "Player2"})
            expectTableEqual(TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("nonadmins", MockPlayers[1])), {"Player3", "Player4"})
            expect(#TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("random", MockPlayers[1]))).to.equal(1)
            expect(#TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("?", MockPlayers[1]))).to.equal(1)
            expect(#TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("?3", MockPlayers[1]))).to.equal(3)
            expect(#TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("?6", MockPlayers[1]))).to.equal(4)
            
            --Test the players.
            expectTableEqual(TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("someName", MockPlayers[1])), {"Player1", "Player2", "Player3"})

            --Test the teams.
            expectTableEqual(TestNexusAdminPlayers.Autocomplete(TestNexusAdminPlayers.Transform("%test", MockPlayers[1])), {"%TestTeam"})
        end)

        it("should parse players.", function()
            local function expectTableEqual(Table1, Table2)
                for i = 1, math.max(#Table1, #Table2) do
                    expect(Table1[i]).to.equal(Table2[i])
                end
            end

            --Test the shorthands.
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("", MockPlayers[1])), {})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform(".", MockPlayers[1])), {MockPlayers[1]})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("me", MockPlayers[1])), {MockPlayers[1]})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("*", MockPlayers[1])), {MockPlayers[1], MockPlayers[2], MockPlayers[3], MockPlayers[4]})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("all", MockPlayers[1])), {MockPlayers[1], MockPlayers[2], MockPlayers[3], MockPlayers[4]})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("others", MockPlayers[1])), {MockPlayers[2], MockPlayers[3], MockPlayers[4]})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("admins", MockPlayers[1])), {MockPlayers[1], MockPlayers[2]})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("nonadmins", MockPlayers[1])), {MockPlayers[3], MockPlayers[4]})
            expect(#TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("random", MockPlayers[1]))).to.equal(1)
            expect(#TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("?", MockPlayers[1]))).to.equal(1)
            expect(#TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("?3", MockPlayers[1]))).to.equal(3)
            expect(#TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("?6", MockPlayers[1]))).to.equal(4)
            
            --Test the players.
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("someName", MockPlayers[1])), {MockPlayers[1], MockPlayers[2], MockPlayers[3]})

            --Test the teams.
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("%test", MockPlayers[1])), {MockPlayers[1], MockPlayers[3]})
        end)

        it("should parse players with filters.", function()
            local function expectTableEqual(Table1, Table2)
                for i = 1, math.max(#Table1, #Table2) do
                    expect(Table1[i]).to.equal(Table2[i])
                end
            end

            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("all[me]", MockPlayers[1])), {MockPlayers[1]})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("not[me]", MockPlayers[1])), {MockPlayers[2], MockPlayers[3], MockPlayers[4]})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("others[me]", MockPlayers[1])), {})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("me[others]", MockPlayers[1])), {})
            expect(#TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("others[?6]", MockPlayers[1]))).to.equal(3)
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("others[%test]", MockPlayers[1])), {MockPlayers[3]})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("not[%test]", MockPlayers[1])), {MockPlayers[2], MockPlayers[4]})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("%test[others]", MockPlayers[1])), {MockPlayers[3]})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("all[me,others]", MockPlayers[1])), {MockPlayers[1], MockPlayers[2], MockPlayers[3], MockPlayers[4]})
            expectTableEqual(TestNexusAdminPlayers.Parse(TestNexusAdminPlayers.Transform("not[not[%test],me]", MockPlayers[1])), {MockPlayers[3]})
        end)
    end)
end