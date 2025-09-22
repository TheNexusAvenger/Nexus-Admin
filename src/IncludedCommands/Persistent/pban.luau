--Implementation of a command.
--!strict

--Roblox Ban API allows up to 400 characters.
local DISPLAY_REASON_CHARACTER_LIMIT = 400
--Roblox Ban API allows up to 1000 characters, pban saves 50 of those characters to append the moderator to the end.
local PRIVATE_REASON_CHARACTER_LIMIT = 950 

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))


return {
    Keyword = "pban",
    Category = "PersistentCommands",
    Description = "Bans a set of players by their user id or username (use user if the name is a number).",
    Arguments = {
        {
            Type = "strings",
            Name = "Names",
            Description = "Players to ban.",
        },
        {
            Type = "duration",
            Name = "Duration",
            Description = "How long the ban is.\nDuration < 0 will be permanent.\nDefaults to -1Seconds",
            Default = -1 :: any, --Required to make type not number.
            Optional = true,
        },
        {
            Type = "boolean",
            Name = "Experience Wide",
            Description = "Should the ban apply to all places within the experience.\nDefaults to true",
            Default = true,
            Optional = true,
        },
        {
            Type = "boolean",
            Name = "Include Alts",
            Description = "Should the ban apply to all suspected alts.\nDefaults to true",
            Default = true,
            Optional = true,
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans")).GetInstance(Api)

        local GetReasonsRemote = (IncludedCommandUtil:CreateRemote("RemoteEvent","PersistentBan") :: RemoteEvent)
        local SendResponseRemote = (IncludedCommandUtil:CreateRemote("RemoteEvent", "PersistentBanResponse") :: RemoteEvent)
        GetReasonsRemote.OnServerEvent:Connect(function(Player, Ids: {number}, Duration: number, ExperienceWide: boolean, IncludeAlts: boolean)
            --Return if the user is not authorized.
            if not Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("PersistentCommands", "pban")) then
                return
            end

            --Get and validate the dipslay and private reasons.
            local VarStore = Api.Cmdr.Registry:GetStore(`var_{Player.UserId}`)
            local DisplayReason = VarStore["DisplayReason"]
            local PrivateReason = VarStore["PrivateReason"]

            if string.len(DisplayReason) == 0 then
                DisplayReason = "No reason provided."
            elseif string.len(DisplayReason) > DISPLAY_REASON_CHARACTER_LIMIT then
                Api.Messages:DisplayHint(Player, `Display Reason Character Limit exceeded. {string.len(DisplayReason)}/{DISPLAY_REASON_CHARACTER_LIMIT}`, 5)
                return GetReasonsRemote:FireClient(Player, Ids, Duration, ExperienceWide, IncludeAlts)
            end

            if string.len(PrivateReason) == 0 then
                PrivateReason = DisplayReason
            elseif string.len(PrivateReason) > PRIVATE_REASON_CHARACTER_LIMIT then
                Api.Messages:DisplayHint(Player, `Private Reason Character Limit exceeded. {string.len(PrivateReason)}/{PRIVATE_REASON_CHARACTER_LIMIT}`, 5)
                return GetReasonsRemote:FireClient(Player, Ids, Duration, ExperienceWide, IncludeAlts)
            end
            PrivateReason ..= `\nModerator: @{Player.Name}`

            --Ban the ids.
            local Success, Response, BannedIds, ImmuneIds = PersistentBans:BanIds({
                ["UserIds"] = Ids,
                ["Duration"] = Duration,
                ["DisplayReason"] = DisplayReason,
                ["PrivateReason"] = PrivateReason,
                ["ApplyToUniverse"] = ExperienceWide,
                ["ExcludeAltAccounts"] = not IncludeAlts,
            }, Player.UserId, Player.Name)
            SendResponseRemote:FireClient(Player, "Ban", Success, Response, BannedIds, ImmuneIds)

            --Reset the variables.
            VarStore["DisplayReason"] = nil
            VarStore["PrivateReason"] = nil
        end)
    end,
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        local Executor = Api.Executor :: Types.Executor
        local Messages = Api.Messages :: Types.MessagesClient

        local DisplayReasonMessage = "run edit ${var .DisplayReason} \\\\\n && var= .DisplayReason ||"
        local PrivateReasonMessage = "run edit ${var .PrivateReason} \\\\\n && var= .PrivateReason ||"

        local GetReasonsRemote = IncludedCommandUtil:GetRemote("PersistentBan") :: RemoteEvent

        GetReasonsRemote.OnClientEvent:Connect(function(...)
            Messages:DisplayHint(`Persistent Bans: Please provide an optional Display Ban Message. This will be shown to the banned individual(s). {DISPLAY_REASON_CHARACTER_LIMIT}} Character Limit.`, 10)
            Executor:ExecuteCommandWithOrWithoutPrefix(DisplayReasonMessage, Players.LocalPlayer)

            Messages:DisplayHint(`Persistent Bans: Please provide an optional Private Ban Message. This will be visible only to user(s) authorized to access :pbans. {PRIVATE_REASON_CHARACTER_LIMIT} Character Limit.`, 10)
            Executor:ExecuteCommandWithOrWithoutPrefix(PrivateReasonMessage, Players.LocalPlayer)

            GetReasonsRemote:FireServer(...)
        end)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, PlayerNames: {string}, Duration: number, ExperienceWide: boolean, IncludeAlts: boolean): string?
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans")).GetInstance(Api)

        --Return if the persistent bans weren't initialized.
        if not PersistentBans:WasInitialized() then
            if PersistentBans.Enabled then
                return "Persistent bans failed to initialize."
            else
                return "Roblox Ban API is disabled within this experience."
            end
        end

        --Resolve the names.
        local Ids = {}
        for _,Name in PlayerNames do
            for _, Id in PersistentBans:ResolveUserIds(Name) do
                table.insert(Ids, Id)
            end
        end

        --Send Request to appropriate client as to provide the reasons for the ban. 
        (Util:GetRemote("PersistentBan") :: RemoteEvent):FireClient(CommandContext.Executor, Ids, Duration, ExperienceWide, IncludeAlts)  
        return nil
    end,
}