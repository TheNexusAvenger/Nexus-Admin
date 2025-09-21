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
                            PersistentBanHistories[Id] = {Error = Response}
                        end
                    end

                    return PersistentBanHistories,CompletedUsernameCache
                else
                    if Api.CommandData.PersistentBans.Enabled then
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

        local function IsolateErrorResponses(Error: string): {{UserId: number, Lines: {string}}}
            --EXAMPLE
            --HTTP 429 failure for UserId 135955170: { "code": "RESOURCE_EXHAUSTED", "message": "You have made too many requests for user 135955170 in this universe or place in a short period. Please try again." }, HTTP 429 failure for UserId 799258: { "code": "RESOURCE_EXHAUSTED", "message": "You have made too many requests for user 799258 in this universe or place in a short period. Please try again." }, HTTP 429 failure for UserId 735798: { "code": "RESOURCE_EXHAUSTED", "message": "You have made too many requests for user 735798 in this universe or place in a short period. Please try again." }, HTTP 429 failure for UserId 6443947: { "code": "RESOURCE_EXHAUSTED", "message": "You have made too many requests for user 6443947 in this universe or place in a short period. Please try again." }
            local Response = {} :: {
                {
                    UserId: number,
                    Lines: {
                        string
                    }
                }
            }
            local Individuals = {}
            local Built = ""
            for _, i in string.split(Error, ",") do
                if Built == "" then
                    Built = i
                else
                    Built = `{Built},{i}`
                end
                if string.sub(Built, string.len(Built)) == "}" then
                    table.insert(Individuals, Built)
                    Built = ""
                end
            end

            for _, Message in Individuals do
                local Split1 = string.split(Message, ": {")
                local ColonPosition,_ = string.find(Message, ":")
                if not ColonPosition then
                    table.insert(Response, {
                        UserId = -1,
                        Lines = {
                            "Unable to Parse Error Message:",
                            Message
                        }
                    })
                    continue
                end
                local RawJSON = string.sub(Message, ColonPosition + 1)
                local ParsedJSON
                pcall(function()
                    ParsedJSON = HttpService:JSONDecode(RawJSON) :: {code: string, message: string}
                end)

                --Isolate the UserId
                local Split2 = string.split(Split1[1], " ")
                local UserId = Split2[#Split2]

                if ParsedJSON then
                    ParsedJSON = (ParsedJSON :: {code: string, message: string})
                    table.insert(Response, {
                        UserId = tonumber(UserId),
                        Lines = {
                            `Code: {ParsedJSON.code}`,
                            `Message:`,
                            ParsedJSON.message,
                            "",
                            "Full Error Message:",
                            Message
                        }
                    })
                else
                    table.insert(Response, {
                        UserId = tonumber(UserId),
                        Lines = {
                            `Unable to parse JSON`,
                            "",
                            "Full Error Message:",
                            Message
                        }
                    })
                end
            end
            return Response
        end

        ResponseRemote.OnClientEvent:Connect(function(Action: "Ban" | "Unban", Success: boolean, Response: string, BannedIds: {number}, ImmuneIds: {number})
            --Show the window.
            local Window = Api.Window:CreateWindow(`Persistent {Action}`)
            local TextList = Window:AddTextList()

            local DecodedErrorMessage

            if not Success then
                DecodedErrorMessage = IsolateErrorResponses(Response)
            end

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
                    table.insert(Lines, "Errored Users:")
                    for _, ErrorMessage: {UserId: number, Lines: {string}} in DecodedErrorMessage do
                        table.insert(Lines, "")
                        if ErrorMessage.UserId > 0 then
                            table.insert(Lines, `User: @{GetCachedUsername(ErrorMessage.UserId)} ({ErrorMessage.UserId})`)
                        end
                        for _, Line in ErrorMessage.Lines do
                            table.insert(Lines, Line)
                        end
                    end
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
            local TextList = Window:AddTextList(nil,true)
            TextList:EnableSearching()

            local function UpdateText()
                TextList:SetLines({"Loading..."})
                Window:SetTitle(`@{GetCachedUsername(UserId)} ({UserId})'s Ban History`)

                local Lines = {}
                local ErrorMessage = (History :: BanHistoryError ).Error
                if ErrorMessage then
                    table.insert(Lines, `Failed to get @{GetCachedUsername(UserId)} ({UserId})'s Ban History`)
                    table.insert(Lines, "")
                    table.insert(Lines, `Error: {ErrorMessage}`)
                else
                    --Format the lines.
                    --Username fetching is done on the client in case the server didn't load it in time.
                    table.insert(Lines, `<b>Start of @{GetCachedUsername(UserId)} ({UserId})'s Ban History</b>`)
                    table.insert(Lines, "----------")
                    for _, BanPage in History :: {{BanHistoryPage}} do
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
                    table.insert(Lines, {Text = `End of @{GetCachedUsername(UserId)} ({UserId})'s Ban History`, Font = Enum.Font.SourceSansBold})
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