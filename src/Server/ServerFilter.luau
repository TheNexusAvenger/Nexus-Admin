--Filters strings to comply with Roblox's filtering rules.
--!strict

local CANT_SEE_CHAT_MESSAGE = "(Your chat settings prevent you from seeing messages)"

local Filter = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("Filter"))

local ServerFilter = {}
ServerFilter.__index = ServerFilter
setmetatable(ServerFilter, Filter)

export type ServerFilter = typeof(setmetatable({}, ServerFilter)) & Filter.Filter



--[[
Creates a filter instance.
--]]
function ServerFilter.new(): ServerFilter
    return setmetatable(Filter.new(), ServerFilter) :: ServerFilter
end

--[[
Filters a string for a user.
--]]
function ServerFilter.FilterString(self: ServerFilter, String: string, PlayerFrom: Player, PlayerTo: Player?): string
    if PlayerTo then
        warn("ServerFilter::FilterString with PlayerTo is deprecated in Nexus Admin 2.9.0 due to TextChatService changes (https://devforum.roblox.com/t/textservice-filtering-returns-empty-message-for-valid-text-input/3650504).")
    end

    --Return the string if it is an empty string.
    if not string.match(String, "([%w%p])") then return String end

    --Filter the string.
    local Worked, Return = pcall(function()
        if PlayerTo then
            if self.Chat:CanUsersChatAsync(PlayerFrom.UserId, PlayerTo.UserId) then
                return self.TextService:FilterStringAsync(String, PlayerFrom.UserId, Enum.TextFilterContext.PrivateChat):GetNonChatStringForUserAsync(PlayerTo.UserId)
            else
                return CANT_SEE_CHAT_MESSAGE
            end
        else
            return self.TextService:FilterStringAsync(String, PlayerFrom.UserId, Enum.TextFilterContext.PublicChat):GetNonChatStringForBroadcastAsync()
        end
    end)
    
    --Return the message.
    if Worked and Return then
        return Return
    else
        warn(`Filter string failed for "{String}" because {Return}`)
        return string.gsub(String, "[^%s]", "#")
    end
end

--[[
Filters a string for a set of users.
Returns a map of the players to their filtered string.
--]]
function ServerFilter.FilterStringForPlayers(self: ServerFilter, String: string, PlayerFrom: Player, PlayersTo: {Player}): {[Player]: string}
    warn("ServerFilter::FilterStringForPlayers is deprecated in Nexus Admin 2.9.0 due to TextChatService changes (https://devforum.roblox.com/t/textservice-filtering-returns-empty-message-for-valid-text-input/3650504).")

    --Return the string if it is an empty string.
    local FilteredResults = {}
    if not string.match(String,"([%w%p])") then
        for _,Player in PlayersTo do
            FilteredResults[Player] = String
        end
        return FilteredResults
    end

    --Add the filtered strings for the players.
    local Worked, Return = pcall(function()
        local FilterObject = self.TextService:FilterStringAsync(String,PlayerFrom.UserId, Enum.TextFilterContext.PrivateChat)
        for _, Player in PlayersTo do
            local Worked, Return = pcall(function()
                if self.Chat:CanUsersChatAsync(PlayerFrom.UserId, Player.UserId) then
                    FilteredResults[Player] = FilterObject:GetNonChatStringForUserAsync(Player.UserId)
                else
                    FilteredResults[Player] = CANT_SEE_CHAT_MESSAGE
                end
            end)
            if not Worked then
                warn(`Filter string for player {Player} failed for "{String}"  because {Return}`)
            end
        end
    end)
    if not Worked then
        warn(`Filter string failed for "{String}"  because {Return}`)
    end

    --Add the missing filtered strings.
    local BaseFilteredString
    for _, Player in PlayersTo do
        if not FilteredResults[Player] then
            if not BaseFilteredString then
                BaseFilteredString = self:FilterString(String,PlayerFrom)
            end
            FilteredResults[Player] = BaseFilteredString
        end
    end 

    --Return the filtered results.
    return FilteredResults
end



return ServerFilter