--Implementation of a command.
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

local function SecondsToTime(Seconds : number) : string
    local Days = math.floor(Seconds/(60*60*24))
    local D_Remainder = Seconds%(60*60*24)
    local Hours = math.floor(D_Remainder/(60*60))
    local H_Remainder = D_Remainder%(60*60)
    local Minutes = math.floor(H_Remainder/60)
    local Seconds = H_Remainder%60

    return `{Days} Days; {Hours} Hours; {Minutes} Minutes; {Seconds} Seconds`
end

return {
    Keyword = "pbanlogs",
    Category = "PersistentCommands",
    Description = "Displays the Persistent Bans and Unban Actions done through NexusAdmin.",
    Arguments = {},
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))
        Api.CommandData.PersistentBans = PersistentBans.GetInstance(Api)

        Api.CommandData.LegacyPersistentBans = Api.CommandData.PersistentBans.IsLegacy;

        if Api.CommandData.LegacyPersistentBans then
            return
        end
        
        local NexusDataStore = require(ReplicatedStorage:WaitForChild("NexusAdminClient"):WaitForChild("Packages"):WaitForChild("NexusDataStore")) :: any
        xpcall(function()
            Api.CommandData.PersistentBanLogsDataStore = NexusDataStore:GetDataStore("NexusAdmin_Persistence", "PersistentBan_Logs")
        end, function(ErrorMessage)
            warn(`Failed to get persistent ban logs because {ErrorMessage}`)
        end)

        local GetPersistentBanLogsFunction = Instance.new("RemoteFunction")
        GetPersistentBanLogsFunction.Name = "GetPersistentBanLogs"
        GetPersistentBanLogsFunction.Parent = Api.EventContainer

        function GetPersistentBanLogsFunction.OnServerInvoke(Player): {string}
            if Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("PersistentCommands", "pbanlogs")) then
                if Api.CommandData.PersistentBanLogsDataStore then
                    local LogEntries = Api.CommandData.PersistentBanLogsDataStore:Get("PersistentBanActionsLog") or {}
                    local Logs = {}
                    --[[
                    Moderator Values:
                        #>0 = User
                        #<=0 = Specified By Script
                        
                    Action Values:
                        0 = Ban
                        1 = Unban
                    ]]
                    for i = #LogEntries, 1, -1 do
                        local Log = LogEntries[i]
                        local ModeratorString = ""
                        if Log.Id then
                            if Log.Id <= 0 then
                                ModeratorString = Log.Name or "NexusAdmin"
                            else
                                ModeratorString = `@{Log.Name} ({Log.Id})`
                            end
                        else
                            ModeratorString = "NexusAdmin"
                        end
                        if Log.Action == 0 then
                            table.insert(Logs,`{ModeratorString} banned UserIds: \{{table.concat(Log.EffectedUserIds,", ")}\} at {Api.Time:GetDateTimeString(Log.Time)}, with a duration of ({Log.Duration == -1 and "Permanent" or SecondsToTime(Log.Duration)}) {Log.ExpWide and "across the entire experience" or "in a single place"}, {Log.IncludeAlts and "including possible alt accounts" or "excluding possible alt accounts"}.`)
                        else
                            table.insert(Logs,`{ModeratorString} unbanned UerIds: \{{table.concat(Log.EffectedUserIds,", ")}\} at {Api.Time:GetDateTimeString(Log.Time)}, {Log.ExpWide and "across the entire experience" or "in a single place"}.`)
                        end
                    end
                    return Logs
                else
                    return {"Logs failed to load."}
                end
            else
                return {"Unauthorized"}
            end
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext): string?
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        --Return if persistent bans is the legacy system.
        if (Util:GetRemote("LegacyPersistentBansCheck") :: RemoteFunction):InvokeServer() then
            return "Overhauled persistent bans disabled within this experience. :pbanlogs does not support the Legacy Persistent Bans system."
        end

        --Show the window.
        local Window = Api.Window:CreateWindow("Persistent Ban Logs")
        local TextList = Window:AddTextList()
        TextList:EnableSearching()
        
        local function UpdateText()
            TextList:SetLines({"Loading..."})
            TextList:SetLines((Api.EventContainer:WaitForChild("GetPersistentBanLogs") :: RemoteFunction):InvokeServer())
        end

        task.spawn(UpdateText)
        Window:EnableRefreshing(UpdateText)
        Window:EnableClosing()
        Window:EnableResizing()
        Window:Show()
    end,
}