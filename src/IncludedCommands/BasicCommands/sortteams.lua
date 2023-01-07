--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "sortteams",
    Category = "BasicCommands",
    Description = "Splits the given players into teams with some randomness.",
    Arguments = {
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
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        --Set the default sort method.
        --No sorting is done by default, but some services use custom initial sorting.
        if not Api.CommandData.SortTeamsSortMethod then
            Api.CommandData.SortTeamsSortMethod = function(Players)
                return Players
            end
        end
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Teams: {Team})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Sort the players.
        if Api.CommandData.SortTeamsSortMethod then
            Players = Api.CommandData.SortTeamsSortMethod(Players)
        end

        --Assign the players to teams.
        --Players are sorted and then randomized in groupings by team.
        for i = 1, math.ceil(#Players / #Teams) do
            --Determine the team indexes and randomize them.
            local TeamIndexes = {}
            for j = 1, #Teams do
                table.insert(TeamIndexes, j)
            end
            for j = 1, #TeamIndexes - 1 do
                local RandomIndex = math.random(j, #TeamIndexes)
                TeamIndexes[j], TeamIndexes[RandomIndex] = TeamIndexes[RandomIndex], TeamIndexes[j]
            end

            --Assign the players.
            for j, TeamIndex in TeamIndexes do
                local PlayerIndex = j + ((i - 1) * #TeamIndexes)
                local Player = Players[PlayerIndex]
                if Player then
                    Player.Neutral = false
                    Players[PlayerIndex].TeamColor = Teams[TeamIndex].TeamColor
                end
            end
        end
    end,
}