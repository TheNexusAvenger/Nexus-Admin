--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "pbans",
    Category = "PersistentCommands",
    Description = "Displays a list of all permanent bans.",
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))
        Api.CommandData.PersistentBans = PersistentBans.GetInstance(Api)

        --[[
        Returns the name for the user id.
        --]]
        local UserNameCache = {}
        local function GetUserName(UserId)
            --Add the name to the cache.
            if not UserNameCache[UserId] then
                UserNameCache[UserId] = "[NAME FETCH FAILED]"
                pcall(function()
                    UserNameCache[UserId] = Players:GetNameFromUserIdAsync(UserId)
                end)
            end

            --Return the cached username.
            return UserNameCache[UserId]
        end
        
        --Create the remote function.
        local GetPersistentBansRemoteFunction = IncludedCommandUtil:CreateRemote("RemoteFunction", "GetPersistentBans") :: RemoteFunction
        function GetPersistentBansRemoteFunction.OnServerInvoke(Player)
            if Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("PersistentCommands", "pbans")) then
                if Api.CommandData.PersistentBans:WasInitialized() then
                    --Create the messages list.
                    local BannedPlayers = {}
                    for UserId, Message in Api.CommandData.PersistentBans.BansDataStore.Data do
                        if Message == true then
                            table.insert(BannedPlayers, GetUserName(UserId).." ("..tostring(UserId)..")")
                        else
                            table.insert(BannedPlayers, GetUserName(UserId).." ("..tostring(UserId)..") - "..tostring(Message))
                        end
                    end

                    --Sort and return the messages.
                    table.sort(BannedPlayers, function(a, b) return string.lower(a) < string.lower(b) end)
                    return BannedPlayers
                else
                    return {"Persistent bans failed to initialize"}
                end
            else
                return {"Unauthorized"}
            end
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local Bans = nil
        local Window = ScrollingTextWindow.new()
        Window.Title = "Persistent Bans"
        Window.GetTextLines = function(_, SearchTerm, ForceRefresh)
            --Get the bans.
            if not Bans or ForceRefresh then
                Bans = (Util:GetRemote("GetPersistentBans") :: RemoteFunction):InvokeServer()
            end

            --Filter and return the bans.
            local FilteredBans = {}
            for _, Message in Bans do
                if string.find(string.lower(Message), string.lower(SearchTerm)) then
                    table.insert(FilteredBans, Message)
                end
            end
            return FilteredBans
        end
        Window:Show()
    end,
}