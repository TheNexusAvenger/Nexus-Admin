--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

local UsernameCache = {}
local CompletedUsernameCache = {}
local UsernameFetchQueue = {}
local UsernameLoaded = Instance.new("BindableEvent")



--[[
Returns the username.
--]]
local function GetCachedUsername(UserId: number): string
    if not UsernameCache[UserId] then
        --Queue fetching the username.
        local UsernameQueueActive = (#UsernameFetchQueue ~= 0)
        table.insert(UsernameFetchQueue, UserId)
        UsernameCache[UserId] = "(Loading...)"

        --Perform the queue if it isn't active already.
        --This is not done in parallel due to request limits.
        if not UsernameQueueActive then
            task.spawn(function()
                while #UsernameFetchQueue > 0 do
                    local NextUserId = UsernameFetchQueue[1]
                    xpcall(function()
                        UsernameCache[NextUserId] = Players:GetNameFromUserIdAsync(NextUserId)
                        CompletedUsernameCache[tostring(NextUserId)] = UsernameCache[NextUserId]
                        table.remove(UsernameFetchQueue, 1)
                    end, function(ErrorMessage)
                        if string.find(ErrorMessage, "HTTP 429") then
                            --Wait to retry if too many requests were sent.
                            task.wait(1)
                        else
                            --Consider the fetch as failed.
                            UsernameCache[NextUserId] = "[NAME FETCH FAILED]"
                            warn(`Failed to get username for {NextUserId} because {ErrorMessage}`)
                        end
                    end)
                    UsernameLoaded:Fire()
                end
            end)
        end
    end
    return UsernameCache[UserId]
end



return {
    Keyword = "pbans",
    Category = "PersistentCommands",
    Description = "Displays a list of all permanent bans.",
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))
        Api.CommandData.PersistentBans = PersistentBans.GetInstance(Api)
        
        --Create the remote function.
        local GetPersistentBansRemoteFunction = IncludedCommandUtil:CreateRemote("RemoteFunction", "GetPersistentBans") :: RemoteFunction
        function GetPersistentBansRemoteFunction.OnServerInvoke(Player)
            if Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("PersistentCommands", "pbans")) then
                if Api.CommandData.PersistentBans:WasInitialized() then
                    return Api.CommandData.PersistentBans.BansDataStore.Data, CompletedUsernameCache
                else
                    return "Persistent bans failed to initialize", {}
                end
            else
                return "Unauthorized", {}
            end
        end

        --Populate the the username cache.
        if Api.CommandData.PersistentBans:WasInitialized() then
            task.spawn(function()
                for UserId, _ in Api.CommandData.PersistentBans.BansDataStore.Data do
                    GetCachedUsername(UserId)
                end
            end)
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local Bans = nil
        local Lines: {string}? = nil
        local UsernameLoadedConnection: RBXScriptConnection? = nil
        local Window = ScrollingTextWindow.new()
        local OriginalOnClose = ScrollingTextWindow.OnClose
        Window.Title = "Persistent Bans"
        Window.GetTextLines = function(_, SearchTerm, ForceRefresh)
            --Get the bans.
            if not Bans or ForceRefresh then
                local NewBans, NewUsernameCache = (Util:GetRemote("GetPersistentBans") :: RemoteFunction):InvokeServer()
                for UserId, Username in NewUsernameCache do
                    if not UsernameCache[UserId] then
                        UsernameCache[UserId] = Username
                    end
                end
                Bans = NewBans
                Lines = nil
            end

            --Format the lines.
            --Username fetching is done on the client in case the server didn't load it in time.
            if not Lines then
                if typeof(Bans) == "string" then
                    Lines = {Bans}
                else
                    local NewLines = {}
                    for UserId, Message in Bans do
                        if Message == true then
                            table.insert(NewLines, `{GetCachedUsername(UserId)} ({UserId})`)
                        else
                            table.insert(NewLines, `{GetCachedUsername(UserId)} ({UserId}) - {Message}`)
                        end
                    end
                    table.sort(NewLines, function(a, b) return string.lower(a) < string.lower(b) end)
                    Lines = NewLines
                end
            end

            --Filter and return the bans.
            local FilteredBans = {}
            for _, Message in Lines :: {string} do
                if string.find(string.lower(Message), string.lower(SearchTerm)) then
                    table.insert(FilteredBans, Message)
                end
            end
            return FilteredBans
        end
        Window.OnClose = function(...)
            if UsernameLoadedConnection then
                UsernameLoadedConnection:Disconnect()
                UsernameLoadedConnection = nil
            end
            OriginalOnClose(...)
        end
        Window:Show()

        --Conneced cached usernames loading.
        UsernameLoadedConnection = UsernameLoaded.Event:Connect(function()
            Lines = nil
            Window:UpdateText()
        end)
    end,
}