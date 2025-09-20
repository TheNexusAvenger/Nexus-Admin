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

local function PagesToTable(Pages)
    local Items = {}
    while not Pages.IsFinished do
        table.insert(Items, Pages:GetCurrentPage())
        Pages:AdvanceToNextPageAsync()
    end
    return Items
end

type BanHistoryPage = {
    DisplayReason: string,
    PrivateReason: string,
    StartTime: string,
    Duration: number,
    Ban: boolean,
    PlaceId: number,
}

return {
    Keyword = "pbans",
    Category = "PersistentCommands",
    Description = "Displays the ban history of a set of players by their user id or username (use user if the name is a number).",
    Arguments = {
        {
            Type = "strings",
            Name = "Names",
            Description = "Players to view the ban history of.",
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))
        Api.CommandData.PersistentBans = PersistentBans.GetInstance(Api)

        local PersistentBans = Api.CommandData.PersistentBans

        --Create the remote function.
        local GetPersistentBansRemoteFunction = IncludedCommandUtil:CreateRemote("RemoteFunction", "GetPersistentBans") :: RemoteFunction
        function GetPersistentBansRemoteFunction.OnServerInvoke(Player, Names: {number})
            --Resolve the names.
            local Ids = {}
            for _,Name in Names do
                for _, Id in PersistentBans:ResolveUserIds(Name) do
                    table.insert(Ids, Id)
                end
            end
            if Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("PersistentCommands", "pbans")) then
                if Api.CommandData.PersistentBans:WasInitialized() then
                    local PersistentBanHistories = {}

                    for _, Id in Ids do
                        GetCachedUsername(Id)
                        local Success, Response = pcall(Players.GetBanHistoryAsync, Players, Id)
                        if Success then
                            PersistentBanHistories[Id] = PagesToTable(Response)
                        else
                            PersistentBanHistories[Id] = {err = Response}
                        end
                    end

                    return PersistentBanHistories,CompletedUsernameCache
                else
                    if Api.CommandData.PersistentBans.Enabled then
                        return "Persistent bans failed to initialize.", {}
                    else
                        return "RobloxBanAPI is disabled within this experience.", {}
                    end
                end
            else
                return "Unauthorized", {}
            end
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Names: {string})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        local Bans, NewUserNameCache = (Util:GetRemote("GetPersistentBans") :: RemoteFunction):InvokeServer(Names)

        if typeof(Bans) == "string" then
            return Bans
        end

        for UserId, Username in NewUserNameCache do
            if not UsernameCache[UserId] then
                UsernameCache[UserId] = Username
            end
        end

        for UserId, History: {{BanHistoryPage}} in Bans do
            --Show the window.
            local Window = Api.Window:CreateWindow(`Ban History: {(UsernameCache[UserId] or tostring(UserId))}`)
            local TextList = Window:AddTextList()
            TextList:EnableSearching()

            local function UpdateText()
                TextList:SetLines({"Loading..."})

                local Lines = {}
                if History.err then
                    table.insert(Lines, `Failed to get {UsernameCache[UserId] or UserId}'s Ban History`)
                    table.insert(Lines, "")
                    table.insert(Lines, `Error: {History.err}`)
                else
                    --Format the lines.
                    --Username fetching is done on the client in case the server didn't load it in time.
                    table.insert(Lines, {Text = `Start of {UsernameCache[UserId] or UserId}'s Ban History`, Font = Enum.Font.SourceSansBold})
                    table.insert(Lines, "----------")
                    for _, BanPage : {BanHistoryPage} in History do
                        for _, Ban in BanPage do
                            table.insert(Lines, `Effective Date: {Ban.StartTime}`)
                            table.insert(Lines, "")
                            table.insert(Lines, `Effective Location: {Ban.PlaceId == -1 and "Entire Experience" or `Single Place ({Ban.PlaceId})`}`)
                            table.insert(Lines, "")
                            if Ban.Ban then
                                table.insert(Lines, "Action: Ban")
                                table.insert(Lines, "")
                                table.insert(Lines, `Duration: {Ban.Duration == -1 and "Permanent" or Api.Time:SecondsToDuration(Ban.Duration)}`)
                                table.insert(Lines, "")
                                table.insert(Lines, "Display Reason - Reason Shown to User")
                                table.insert(Lines, Ban.DisplayReason)
                                table.insert(Lines, "")
                                table.insert(Lines, "Private Reason - Reason Shown to Moderators")
                                table.insert(Lines, Ban.PrivateReason)
                            else
                                table.insert(Lines, "Action: Unban")
                            end
                            table.insert(Lines, "----------")
                        end
                    end
                    table.insert(Lines, {Text = `End of {UsernameCache[UserId] or UserId}'s Ban History`, Font = Enum.Font.SourceSansBold})
                end
                TextList:SetLines(Lines)
            end

            task.spawn(UpdateText)
            Window:EnableClosing()
            Window:EnableResizing()
            Window:Show()
        end
    end,
}