--Implementation of a command.
--!strict
local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")

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
            Description = "How long the ban is.\nBanLength < 0 will be permanent.\nDefaults to -1",
            Default = -1,
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
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))
        Api.CommandData.PersistentBans = PersistentBans.GetInstance(Api)

        local GetReasonsRemote = (IncludedCommandUtil:CreateRemote("RemoteEvent","PersistentBan") :: RemoteEvent)

        local SendResponseRemote = (IncludedCommandUtil:CreateRemote("RemoteEvent", "PersistentBanResponse") :: RemoteEvent)

        GetReasonsRemote.OnServerEvent:Connect(function(Player, Ids: {number}, Duration: number, ExperienceWide: boolean, IncludeAlts: boolean)
            if not Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("PersistentCommands", "pban")) then
                return
            end

            local VarStore = Api.Cmdr.Registry:GetStore("var_"..tostring(Player.UserId))

            local DisplayReason = VarStore['DisplayReason']
            local PrivateReason = VarStore['PrivateReason']

            if DisplayReason:len() == 0 then
                DisplayReason = "No reason provided."
            elseif DisplayReason:len() > 400 then
                Api.Messages:DisplayHint(Player, `Display Reason Character Limit exceeded. {DisplayReason:len()}/400`, 5)
                return GetReasonsRemote:FireClient(Player, Ids, Duration, ExperienceWide, IncludeAlts)
            end

            if PrivateReason:len() == 0 then
                PrivateReason = DisplayReason
            elseif PrivateReason:len() > 950 then
                Api.Messages:DisplayHint(Player, `Private Reason Character Limit exceeded. {PrivateReason:len()}/950`, 5)
                return GetReasonsRemote:FireClient(Player, Ids, Duration, ExperienceWide, IncludeAlts)
            end
            PrivateReason ..= `\nModerator: @{Player.Name}`

            local PersistentBans = Api.CommandData.PersistentBans :: PersistentBans.PersistentBans

            local Success, Response, BannedIds, ImmuneIds = PersistentBans:BanIds({
                ["UserIds"] = Ids,
                ["Duration"] = Duration,
                ["DisplayReason"] = DisplayReason,
                ["PrivateReason"] = PrivateReason,
                ["ApplyToUniverse"] = ExperienceWide,
                ["ExcludeAltAccounts"] = not IncludeAlts,
            }, Player.UserId, Player.Name)

            SendResponseRemote:FireClient(Player, "Ban", Success, Response, BannedIds, ImmuneIds)

            VarStore['DisplayReason'] = nil
            VarStore['PrivateReason'] = nil
        end)
    end,
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        local Executor = Api.Executor :: Types.Executor
        local Messages = Api.Messages :: Types.MessagesClient

        local DisplayReasonMessage = 'run edit ${var .DisplayReason} \\\\\n && var= .DisplayReason ||'
        local PrivateReasonMessage = 'run edit ${var .PrivateReason} \\\\\n && var= .PrivateReason ||'

        local GetReasonsRemote = IncludedCommandUtil:GetRemote("PersistentBan") :: RemoteEvent

        GetReasonsRemote.OnClientEvent:Connect(function(...)
            Messages:DisplayHint("Persistent Bans: Please provide an optional Display Ban Message. This will be shown to the banned individual(s). 400 Character Limit.",10)
            Executor:ExecuteCommandWithOrWithoutPrefix(DisplayReasonMessage, Players.LocalPlayer)

            Messages:DisplayHint("Persistent Bans: Please provide an optional Private Ban Message. This will be visible only to user(s) authorized to access :pbans. 950 Character Limit.",10)
            Executor:ExecuteCommandWithOrWithoutPrefix(PrivateReasonMessage, Players.LocalPlayer)

            GetReasonsRemote:FireServer(...)
        end)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, PlayerNames: {string}, Duration: number, ExperienceWide: boolean, IncludeAlts: boolean): string?
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))

        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        --Return if the persistent bans weren't initialized.
        local PersistentBans = Api.CommandData.PersistentBans :: PersistentBans.PersistentBans
        if not PersistentBans:WasInitialized() then
            if Api.CommandData.PersistentBans.Enabled then
                return {"Persistent bans failed to initialize."}
            else
                return {"RobloxBanAPI is disabled within this experience."}
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