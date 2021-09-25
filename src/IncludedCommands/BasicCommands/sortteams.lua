--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("sortteams","BasicCommands","Splits the given players into teams with some randomness.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to sort.",
        },
        {
            Type = "teams",
            Name = "Teams",
            Description = "Teams to sort to.",
        },
    }

    --Set the default sort method.
    --No sorting is done by default, but some services use custom initial sorting.
    if not self.API.CommandData.SortTeamsSortMethod then
        self.API.CommandData.SortTeamsSortMethod = function(Players)
            return Players
        end
    end
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Teams)
    self.super:Run(CommandContext)

    --Sort the players.
    if self.API.CommandData.SortTeamsSortMethod then
        Players = self.API.CommandData.SortTeamsSortMethod(Players)
    end

    --Assign the players to teams.
    --Players are sorted and then randomized in groupings by team.
    for i = 1,math.ceil(#Players/#Teams) do
        --Determine the team indexes and randomize them.
        local TeamIndexes = {}
        for j = 1,#Teams do
            table.insert(TeamIndexes,j)
        end
        for j = 1,#TeamIndexes - 1 do
            local RandomIndex = math.random(j,#TeamIndexes)
            TeamIndexes[j],TeamIndexes[RandomIndex] = TeamIndexes[RandomIndex],TeamIndexes[j]
        end

        --Assign the players.
        for j,TeamIndex in pairs(TeamIndexes) do
            local PlayerIndex = j + ((i - 1) * #TeamIndexes)
            local Player = Players[PlayerIndex]
            if Player then
                Player.Neutral = false
                Players[PlayerIndex].TeamColor = Teams[TeamIndex].TeamColor
            end
        end
    end
end



return Command