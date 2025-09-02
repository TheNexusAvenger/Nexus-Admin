--Implementation of a command.
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
    Keyword = "pbans-legacy",
    Category = "PersistentCommands",
    Description = "Displays a list of all permanent bans. (Legacy Persistent Bans)",
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))
        Api.CommandData.PersistentBans = PersistentBans.GetInstance(Api)
        
        Api.CommandData.LegacyPersistentBans = Api.CommandData.PersistentBans.IsLegacy
        
        if not Api.CommandData.LegacyPersistentBans then
            return
        end
        
        --Create the remote function.
        local GetPersistentBansRemoteFunction = IncludedCommandUtil:CreateRemote("RemoteFunction", "GetPersistentBans") :: RemoteFunction
        function GetPersistentBansRemoteFunction.OnServerInvoke(Player)
            if not Api.CommandData.LegacyPersistentBans then
                return false
            end
            if Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("PersistentCommands", "pbans-legacy")) then
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
        local Api = Util:GetClientApi()
        
        --Return if persistent bans is the legacy system.
        if not (Util:GetRemote("LegacyPersistentBansCheck") :: RemoteFunction):InvokeServer() then
            return "Overhauled persistent bans is enabled within this experience. Please use :pbans."
        end

        --Show the window.
        local Window = Api.Window:CreateWindow("Persistent Bans")
        local TextList = Window:AddTextList()
        TextList:EnableSearching()

        local function UpdateText()
            TextList:SetLines({"Loading..."})
            
            --Get the bans.
            local Bans, NewUsernameCache = (Util:GetRemote("GetPersistentBans") :: RemoteFunction):InvokeServer()
            for UserId, Username in NewUsernameCache do
                if not UsernameCache[UserId] then
                    UsernameCache[UserId] = Username
                end
            end

            --Format the lines.
            --Username fetching is done on the client in case the server didn't load it in time.
            local Lines = {}
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
            TextList:SetLines(Lines)
        end

        local UsernameLoadedConnection = UsernameLoaded.Event:Connect(UpdateText)
        task.spawn(UpdateText)
        Window:EnableRefreshing(UpdateText)
        Window:EnableClosing(function()
            UsernameLoadedConnection:Disconnect()
        end)
        Window:EnableResizing()
        Window:Show()
    end,
}
