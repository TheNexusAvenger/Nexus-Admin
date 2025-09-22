--Implementation of a command.
--!strict

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

local UsernameCache = {}
local CompletedUsernameCache = {}
local UsernameFetchQueue = {}
local UsernameLoaded = Instance.new("BindableEvent")

type BanHistoryPage = {
    DisplayReason: string,
    PrivateReason: string,
    StartTime: string,
    Duration: number,
    Ban: boolean,
    PlaceId: number,
}
type BanHistoryError = {Error: string}

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

--[[
Converts ban history pages to a list of entries.
--]]
local function PagesToTable(Pages: BanHistoryPages)
    local Items = {}
    while true do
        table.insert(Items, Pages:GetCurrentPage())
        if Pages.IsFinished then
            break
        end
        Pages:AdvanceToNextPageAsync()
    end
    return Items
end

--[[
Returns the error for the ban API.
--]]
local function GetErrorMesage(Error: string): string
    pcall(function()
        Error = HttpService:JSONEncode(Error)["message"] or Error
    end)
    return Error
end



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
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans")).GetInstance(Api)

        --Create the remote function.
        local GetPersistentBansRemoteFunction = IncludedCommandUtil:CreateRemote("RemoteFunction", "GetPersistentBans") :: RemoteFunction
        function GetPersistentBansRemoteFunction.OnServerInvoke(Player, Names: {string})
            --Resolve the names.
            local Ids = {}
            for _,Name in Names do
                for _, Id in PersistentBans:ResolveUserIds(Name) do
                    table.insert(Ids, Id)
                end
            end

            --Get the ban histories.
            if Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("PersistentCommands", "pbans")) then
                if PersistentBans:WasInitialized() then
                    local PersistentBanHistories = {}

                    for _, Id in Ids do
                        GetCachedUsername(Id)
                        local Success, Response = pcall(Players.GetBanHistoryAsync, Players, Id)
                        if Success then
                            PersistentBanHistories[Id] = PagesToTable(Response)
                        else
                            PersistentBanHistories[Id] = {Error = Response}
                        end
                    end

                    return PersistentBanHistories, CompletedUsernameCache
                else
                    if PersistentBans.Enabled then
                        return "Persistent Bans failed to initialize.", {}
                    else
                        return "Roblox Ban API is disabled within this experience.", {}
                    end
                end
            else
                return "Unauthorized", {}
            end
        end
    end,
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        local ResponseRemote = IncludedCommandUtil:GetRemote("PersistentBanResponse") :: RemoteEvent

        ResponseRemote.OnClientEvent:Connect(function(Action: "Ban" | "Unban", Success: boolean, Response: string, BannedIds: {number}, ImmuneIds: {number})
            --Show the window.
            local Window = Api.Window:CreateWindow(`Persistent {Action}`)
            local TextList = Window:AddTextList()

            --Get the error message.
            local DecodedErrorMessage
            if not Success then
                DecodedErrorMessage = GetErrorMesage(Response)
            end

            --Set up the window.
            local function UpdateText()
                local Lines = {}
                if #BannedIds > 0 then
                    table.insert(Lines, `User(s) {Action} Attempted On:`)
                    for _, Id in BannedIds do
                        table.insert(Lines, `@{GetCachedUsername(Id)} ({Id})`)
                    end
                end
                if #ImmuneIds > 0 then
                    if #Lines > 0 then
                        table.insert(Lines, "")
                    end
                    table.insert(Lines, "User(s) Immune to Ban:")
                    for _, Id in ImmuneIds do
                        table.insert(Lines, `@{GetCachedUsername(Id)} ({Id})`)
                    end
                end
                if DecodedErrorMessage then
                    if #Lines > 0 then
                        table.insert(Lines, "")
                    end
                    table.insert(Lines, `Error: {DecodedErrorMessage}`)
                end
                TextList:SetLines(Lines)
            end

            UsernameLoaded.Event:Connect(UpdateText)

            task.spawn(UpdateText)
            Window:EnableClosing()
            Window:EnableResizing()
            Window:Show()
        end)
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Names: {string}): ()
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

        for UserId, History in Bans :: {{{BanHistoryPage}} | BanHistoryError } do
            --Show the window.
            local Window = Api.Window:CreateWindow(`@{GetCachedUsername(UserId)} ({UserId})'s Ban History`)
            local TextList = Window:AddTextList()
            TextList:EnableSearching()

            local function UpdateText()
                TextList:SetLines({"Loading..."})
                Window:SetTitle(`@{GetCachedUsername(UserId)} ({UserId})'s Ban History`)

                local Lines = {} :: {string | {Text: string, Font: Enum.Font}}
                local ErrorMessage = (History :: BanHistoryError ).Error
                if ErrorMessage then
                    table.insert(Lines, `Failed to get @{GetCachedUsername(UserId)} ({UserId})'s Ban History`)
                    table.insert(Lines, "")
                    table.insert(Lines, `Error: {ErrorMessage}`)
                else
                    --Format the lines.
                    --Username fetching is done on the client in case the server didn't load it in time.
                    for _, BanPage in History :: {{BanHistoryPage}} do
                        for _, Ban in BanPage do
                            table.insert(Lines, {Text = `Date: {Ban.StartTime}`, Font = Enum.Font.SourceSansBold})
                            table.insert(Lines, `Location: {Ban.PlaceId == -1 and "Entire Experience" or `Single Place ({Ban.PlaceId})`}`)
                            if Ban.Ban then
                                table.insert(Lines, "Action: Ban")
                                table.insert(Lines, `Duration: {Ban.Duration == -1 and "Permanent" or Api.Time:GetDurationString(Ban.Duration)}`)
                                table.insert(Lines, "")
                                table.insert(Lines, "Display Reason (Reason shown to user)")
                                table.insert(Lines, Ban.DisplayReason)
                                table.insert(Lines, "")
                                table.insert(Lines, "Private Reason (Reason shown to moderators)")
                                table.insert(Lines, Ban.PrivateReason)
                            else
                                table.insert(Lines, "Action: Unban")
                            end
                            table.insert(Lines, "----------")
                        end
                    end
                end
                if #Lines == 0 then
                    table.insert(Lines, {Text = `No ban logs.`, Font = Enum.Font.SourceSansItalic})
                end
                TextList:SetLines(Lines)
            end

            UsernameLoaded.Event:Connect(UpdateText)

            task.spawn(UpdateText)
            Window:EnableClosing()
            Window:EnableResizing()
            Window:Show()
        end
    end,
}