--Implementation of a command.
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "pbanlogs",
    Category = "PersistentCommands",
    Description = "Displays the Persistent Bans and Unban Actions done through NexusAdmin.",
    Arguments = {},
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))
        Api.CommandData.PersistentBans = PersistentBans.GetInstance(Api)

        local GetPersistentBanLogsFunction = Instance.new("RemoteFunction")
        GetPersistentBanLogsFunction.Name = "GetPersistentBanLogs"
        GetPersistentBanLogsFunction.Parent = Api.EventContainer

        function GetPersistentBanLogsFunction.OnServerInvoke(Player): {string}
            if Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("PersistentCommands", "pbanlogs")) then
                if not Api.CommandData.PersistentBans:WasInitialized() then
                    if Api.CommandData.PersistentBans.Enabled then
                        return {"Persistent bans failed to initialize."}
                    else
                        return {"RobloxBanAPI is disabled within this experience."}
                    end
                end
                local LogEntries = Api.CommandData.PersistentBans:GetLogs()
                local Logs = {}
                --[[
                Moderator Values:
                    #>0 = User
                    #<=0 = Specified By Script
                    
                Action Values:
                    0 = Ban
                    1 = Unban
                --]]
                for i = #LogEntries, 1, -1 do
                    local Log = LogEntries[i]
                    if typeof(Log) == "string" then
                        table.insert(Logs, Log)
                    else
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
                            table.insert(Logs, `{ModeratorString} banned UserIds: \{{table.concat(Log.EffectedUserIds,", ")}\} at {Api.Time:GetDateTimeString(Log.Time)}, with a duration of ({Log.Duration == -1 and "Permanent" or Api.Time:SecondsToDuration(Log.Duration)}) {Log.ExperienceWide and "across the entire experience" or "in a single place"}, {Log.IncludeAlts and "including possible alt accounts" or "excluding possible alt accounts"}.`)
                        else
                            table.insert(Logs, `{ModeratorString} unbanned UserIds: \{{table.concat(Log.EffectedUserIds,", ")}\} at {Api.Time:GetDateTimeString(Log.Time)}, {Log.ExperienceWide and "across the entire experience" or "in a single place"}.`)
                        end
                    end
                end
                return Logs
            else
                return {"Unauthorized"}
            end
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext): string?
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

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