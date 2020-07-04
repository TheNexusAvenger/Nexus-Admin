--[[
TheNexusAvenger

Filters strings to comply with Roblox's filtering rules.
--]]

local CANT_SEE_CHAT_MESSAGE = "(Your chat settings prevent you from seeing messages)"

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))

local Filter = NexusObject:Extend()
Filter:SetClassName("Filter")



--[[
Creates a filter instance.
--]]
function Filter:__new(NexusAdminRemotes)
    self:InitializeSuper()

    self.TextService = game:GetService("TextService")
    self.Chat = game:GetService("Chat")
end

--[[
Filters a string for a user.
--]]
function Filter:FilterString(String,PlayerFrom,PlayerTo)
    --Return the string if it is an empty string.
    if not string.match(String,"([%w%p])") then return String end

    --Filter the string.
    local Worked,Return = pcall(function()
		if PlayerTo then
			if self.Chat:CanUsersChatAsync(PlayerFrom.UserId,PlayerTo.UserId) then
				return self.TextService:FilterStringAsync(String,PlayerFrom.UserId,Enum.TextFilterContext.PrivateChat):GetChatForUserAsync(PlayerTo.UserId)
			else
				return CANT_SEE_CHAT_MESSAGE
			end
		else
			return self.TextService:FilterStringAsync(String,PlayerFrom.UserId,Enum.TextFilterContext.PublicChat):GetNonChatStringForBroadcastAsync()
		end
	end)
    
    --Return the message.
	if Worked and Return then
		return Return
	else
		warn("Filter string failed for \""..tostring(String).."\"  because "..tostring(Return).."")
		local NewMessage = string.gsub(String,"[^%s]","#")
		return NewMessage
	end
end

--[[
Filters a string for a set of users.
Returns a map of the players to their filtered string.
--]]
function Filter:FilterStringForPlayers(String,PlayerFrom,PlayersTo)
	--Return the string if it is an empty string.
	local FilteredResults = {}
	if not string.match(String,"([%w%p])") then
		for _,Player in pairs(PlayersTo) do
			FilteredResults[Player] = String
		end
		return FilteredResults
	end

	--Add the filtered strings for the players.
	local Worked,Return = pcall(function()
		local FilterObject = self.TextService:FilterStringAsync(String,PlayerFrom.UserId,Enum.TextFilterContext.PrivateChat)
		for _,Player in pairs(PlayersTo) do
			local Worked,Return = pcall(function()
				if self.Chat:CanUsersChatAsync(PlayerFrom.UserId,Player.UserId) then
					FilteredResults[Player] = FilterObject:GetChatForUserAsync(Player.UserId)
				else
					FilteredResults[Player] = CANT_SEE_CHAT_MESSAGE
				end
			end)
			if not Worked then
				warn("Filter string for player "..tostring(Player).." failed for \""..tostring(String).."\"  because "..tostring(Return).."")
			end
		end
	end)
	if not Worked then
		warn("Filter string failed for \""..tostring(String).."\"  because "..tostring(Return).."")
	end

	--Add the missing filtered strings.
	local BaseFilteredString
	for _,Player in pairs(PlayersTo) do
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



return Filter