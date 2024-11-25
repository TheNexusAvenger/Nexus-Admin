--Custom players type closer to the old
--format. Also adds keywords like admins and nonadmins.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

--[[
Registers the types.
--]]
return function(API: Types.NexusAdminApi, TestPlayersService: Players, TestTeamsService: Teams)
    local PlayersService = TestPlayersService or game:GetService("Players")
    local Teams = TestTeamsService or game:GetService("Teams")
    local ExactShorthands = {} :: {[string]: (Text: string, Executor: Player, Players: {Player}) -> ({Player})}
    local PatternShorthands = {} :: {[string]: (Text: string, Executor: Player, Players: {Player}) -> ({Player})}
    local NexusAdminPlayersType = nil

    --[[
    Returns the players to operate on.
    --]]
    local function GetFilteredPlayers(Text: string, Executor: Player): ({Player})
        local FilterText = string.match(Text, "%[(.+)%]$")
        if FilterText then
            local Players = {}
            local PlayersMap = {}
            for _, TextEntry in string.split(FilterText, ",") do
                for _, Player in NexusAdminPlayersType.Parse(NexusAdminPlayersType.Transform(TextEntry, Executor)) do
                    if not PlayersMap[Player] then
                        PlayersMap[Player] = true
                        table.insert(Players, Player)
                    end
                end
            end 
            return Players
        end
        return PlayersService:GetPlayers()
    end

    --[[
    Returns the teams for a given string. Returns nil if
    the string is not valid for teams.
    --]]
    local function GetTeams(Text: string): {Team}?
        --Return if the message doesn't start with %.
        if string.sub(Text, 1, 1) ~= "%" then
            return nil
        end

        --Return the teams.
        local PreFilterText = string.match(Text, "([^%[]+)%[.+%]$") or Text
        return API.Cmdr.Util.MakeFuzzyFinder(Teams:GetTeams())(string.sub(PreFilterText, 2))
    end

    --[[
    Returns the players for the given string.
    --]]
    local function GetPlayers(Text: string, Executor: Player): {Player}
        --Return if a shorthand exists.
        local PreFilterText = string.match(Text, "([^%[]+)%[.+%]$") or Text
        local LowerText = string.lower(PreFilterText)
        local Players = GetFilteredPlayers(Text, Executor)
        for Shorthand, Callback in ExactShorthands do
            if LowerText == Shorthand then
                return Callback(Text, Executor, Players)
            end
        end
        for Shorthand, Callback in PatternShorthands do
            if string.find(LowerText, Shorthand) then
                return Callback(Text, Executor, Players)
            end
        end

        --Get the results from searching.
        return API.Cmdr.Util.MakeFuzzyFinder(Players :: any)(Text)
    end

    --Create the players type.
    NexusAdminPlayersType = {
        Listable = true,

        --[[
        Transforms the string to a list of fast flags.
        --]]
        Transform = function(Text: string, Executor: Player): {Text: string, Executor: Player}
            return {Text = Text, Executor = Executor}
        end,

        --[[
        Returns if the input is valid and an error message
        for when it is invalid.
        --]]
        Validate = function(ArgumentData: {Text: string, Executor: Player}): (boolean, string)
            --Return the results for teams.
            local Teams = GetTeams(ArgumentData.Text)
            if Teams then
                return #Teams > 0, "No teams were found matching that query."
            end

            --Return the results for players.
            local FoundPlayers = GetPlayers(ArgumentData.Text, ArgumentData.Executor)
            return #FoundPlayers > 0, "No players were found matching that query."
        end,
    
        --[[
        Returns the results for auto completing.
        --]]
        Autocomplete = function(ArgumentData: {Text: string, Executor: Player}): {string}
            --Return the teams.
            local Teams = GetTeams(ArgumentData.Text)
            if Teams then
                local TeamStrings = {}
                for _, Team in Teams do
                    table.insert(TeamStrings, `%{Team.Name}`)
                end
                return TeamStrings
            end

            --Return the players.
            local FoundPlayers = GetPlayers(ArgumentData.Text, ArgumentData.Executor)
            return API.Cmdr.Util.GetNames(FoundPlayers :: any)
        end,

        --[[
        Returns the value to use.
        --]]
        Parse = function(ArgumentData: {Text: string, Executor: Player}): {Player}
            --Return if the text is empty.
            --This prevents incomplete commands (such as with a "player1," instead of "player1") from invoking on everyone.
            if ArgumentData.Text == "" then
                return {}
            end

            --Get the players.
            local Teams = GetTeams(ArgumentData.Text)
            local SelectedPlayers = {}
            if Teams then
                --Get the filter players.
                local AllowedPlayers = {}
                for _, Player in GetFilteredPlayers(ArgumentData.Text, ArgumentData.Executor) do
                    AllowedPlayers[Player] = true
                end

                --Add the team players.
                for _, Team in Teams do
                    for _, Player in (Team:GetPlayers() :: {any}) :: {Player} do
                        if AllowedPlayers[Player] then
                            table.insert(SelectedPlayers, Player)
                        end
                    end
                end
            else
                SelectedPlayers = GetPlayers(ArgumentData.Text, ArgumentData.Executor)
            end

            --Return the players.
            return SelectedPlayers
        end,
    }

    --Register the types.
    API.Cmdr.Registry:RegisterType("nexusAdminPlayers", NexusAdminPlayersType :: any)
    API.Types.NexusAdminPlayers = {
        RegisterShortHand = function(_, Name: string | {string}, Callback: (Text: string, Executor: Player, Players: {Player}) -> ({Player})): ()
            if typeof(Name) == "table" then
                for _, SubName in Name do
                    API.Types.NexusAdminPlayers:RegisterShortHand(SubName, Callback)
                end
            else
                ExactShorthands[string.lower(Name)] = Callback
            end
        end,
        RegisterPatternShortHand = function(_, Name: string | {string}, Callback: (Text: string, Executor: Player, Players: {Player}) -> ({Player})): ()
            if typeof(Name) == "table" then
                for _, SubName in Name do
                    API.Types.NexusAdminPlayers:RegisterPatternShortHand(SubName, Callback)
                end
            else
                PatternShorthands[Name] = Callback
            end
        end,
    } :: any

    --Register the shorthands.
    API.Types.NexusAdminPlayers:RegisterShortHand({"me", "."}, function(Text: string, Executor: Player, Players: {Player}): {Player}
        --Return the executing player if it is contained in the list of players.
        for _, Player in Players do
            if Player == Executor then
                return {Executor}
            end
        end
        return {}
    end)
    API.Types.NexusAdminPlayers:RegisterShortHand({"random", "?"}, function(Text: string, Executor: Player, Players: {Player}): {Player}
        --Return a random player.
        if #Players == 0 then
            return {}
        end
        return {Players[math.random(1, #Players)]}
    end)
    API.Types.NexusAdminPlayers:RegisterShortHand({"all", "*"}, function(Text: string, Executor: Player, Players: {Player}): {Player}
        --Return all of the players.
        return Players
    end)
    API.Types.NexusAdminPlayers:RegisterShortHand("others", function(Text: string, Executor: Player, Players: {Player}): {Player}
        --Return all of the players except for the executor.
        local Others = {}
        for _, Player in Players do
            if Player ~= Executor then
                table.insert(Others, Player)
            end
        end
        return Others
    end)
    API.Types.NexusAdminPlayers:RegisterShortHand("admins", function(Text: string, Executor: Player, Players: {Player}): {Player}
        --Return the admins (Nexus Admin only).
        local Admins = {}
        for _, Player in Players do
            if API.Authorization:IsPlayerAuthorized(Player,0) then
                table.insert(Admins,Player)
            end
        end
        return Admins
    end)
    API.Types.NexusAdminPlayers:RegisterShortHand("nonadmins", function(Text: string, Executor: Player, Players: {Player}): {Player}
        --Return the non-admins (Nexus Admin only).
        local NonAdmins = {}
        for _, Player in Players do
            if not API.Authorization:IsPlayerAuthorized(Player,0) then
                table.insert(NonAdmins,Player)
            end
        end
        return NonAdmins
    end)
    API.Types.NexusAdminPlayers:RegisterPatternShortHand("%?%d+", function(Text: string, Executor: Player, Players: {Player}): {Player}
        --Return a random set of players. Use of "random" is not supported for this.
        local RandomMatch = Text:match("%?(%d+)")
        if RandomMatch then
            local MaxSize = tonumber(RandomMatch)
            if MaxSize and MaxSize > 0 then
                local RandomPlayers = {}
                local RemainingPlayers = {}
                for _, Player in Players do
                    table.insert(RemainingPlayers, Player)
                end
                for i = 1, math.min(MaxSize, #RemainingPlayers) do
                    table.insert(RandomPlayers, table.remove(RemainingPlayers, math.random(1,#RemainingPlayers)) :: Player)
                end

                return RandomPlayers
            end
        end
        return {}
    end)
    API.Types.NexusAdminPlayers:RegisterShortHand("not", function(Text: string, Executor: Player, Players: {Player}): {Player}
        --Return all of players not in the given list of players.
        local NegatedPlayers = {}
        local PlayersMap = {}
        for _, Player in Players do
            PlayersMap[Player] = true
        end
        for _, Player in PlayersService:GetPlayers() do
            if not PlayersMap[Player] then
                table.insert(NegatedPlayers, Player)
            end
        end
        return NegatedPlayers
    end)
end