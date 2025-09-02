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

        Api.CommandData.LegacyPersistentBans = Api.CommandData.PersistentBans.IsLegacy;

        (IncludedCommandUtil:CreateRemote("RemoteFunction","LegacyPersistentBansCheck") :: RemoteFunction).OnServerInvoke = function()
            return Api.CommandData.LegacyPersistentBans
        end

        if Api.CommandData.LegacyPersistentBans then
            return
        end

        local function UserIdToPlayer(Id: number) : Player?
            local Match
            for _, Player in Players:GetPlayers() do
                if Player.UserId == Id then
                    Match = Player
                    break
                end
            end
            return Match
        end

        --Try and filter out Persistent Ban Immune UserIds of both in server players and out of server players.
        local function FilterIds(Ids: {number}, Executor : Player)
            local Filtered = {}
            local PersistentBanImmune = Api.Configuration.CommandConfigurations.PersistentBanImmune
            for i, Id in Ids do
                local Player = UserIdToPlayer(Id)
                local AdminLevel = -1
                if Player then
                    if Player == Executor then
                        continue
                    end
                    AdminLevel = math.max(AdminLevel,Api.Authorization:YieldForAdminLevel(Player))
                else
                    if Api.Configuration.Admins[Id] then
                        AdminLevel = math.max(AdminLevel,Api.Configuration.Admins[Id])
                    end
                    xpcall(function()
                        for _, UserGroupInfo in GroupService:GetGroupsAsync(Id) do
                            local GroupInfo = Api.Configuration.GroupAdminLevels[UserGroupInfo.Id]
                            if GroupInfo then
                                for Rank, NewAdminLevel in GroupInfo do
                                    if UserGroupInfo.Rank >= Rank then
                                        AdminLevel = math.max(AdminLevel,NewAdminLevel)
                                    end
                                end
                            end
                        end
                    end, function(ErrorMessage)
                        warn(`Getting group info failed because {ErrorMessage}`)
                    end)
                end
                if AdminLevel > PersistentBanImmune then
                    continue
                end
                if AdminLevel > Api.Authorization:GetAdminLevel(Executor) then
                    continue
                end
                if AdminLevel < PersistentBanImmune then
                    table.insert(Filtered,Id)
                end
            end
            return Filtered
        end

        local RemoteEvent = (IncludedCommandUtil:CreateRemote("RemoteEvent","PersistentBan") :: RemoteEvent)

        RemoteEvent.OnServerEvent:Connect(function(Player,Ids : {number}, Duration : number, ExpWide : boolean, IncludeAlts : boolean)
            if not Api.Authorization:IsPlayerAuthorized(Player,Api.Configuration:GetCommandAdminLevel("PersistentCommands","pban")) then
                return
            end

            local VarStore = Api.Cmdr.Registry:GetStore("var_"..tostring(Player.UserId))

            local DisplayReason = VarStore['DisplayReason']
            local PrivateReason = VarStore['PrivateReason']

            if DisplayReason:len() == 0 then
                DisplayReason = "No reason provided."
            elseif DisplayReason:len() > 400 then
                Api.Messages:DisplayHint(Player,`Display Reason Character Limit exceeded. {DisplayReason:len()}/400`,5)
                return RemoteEvent:FireClient(Player,Ids,Duration,ExpWide,IncludeAlts)
            end

            if PrivateReason:len() == 0 then
                PrivateReason = DisplayReason
            elseif PrivateReason:len() > 950 then
                Api.Messages:DisplayHint(Player,`Private Reason Character Limit exceeded. {PrivateReason:len()}/950`,5)
                return RemoteEvent:FireClient(Player,Ids,Duration,ExpWide,IncludeAlts)
            end
            PrivateReason ..= `\nModerator: @{Player.Name}`

            Ids = FilterIds(Ids,Player)

            local PersistentBans = Api.CommandData.PersistentBans :: PersistentBans.PersistentBans

            local Success, ErrorMessage = PersistentBans:BanIds({
                ["UserIds"] = Ids,
                ["Duration"] = Duration,
                ["DisplayReason"] = DisplayReason,
                ["PrivateReason"] = PrivateReason,
                ["ApplyToUniverse"] = ExpWide,
                ["ExcludeAltAccounts"] = not IncludeAlts,
            },Player.UserId,Player.Name)

            VarStore['DisplayReason'] = nil
            VarStore['PrivateReason'] = nil
        end)
    end,
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        if Api.Configuration.CommandConfigurations.LegacyPersistentBans then
            return
        end

        local Executor = Api.Executor :: Types.Executor
        local Messages = Api.Messages :: Types.MessagesClient

        local DisplayReasonMessage = 'run edit ${var .DisplayReason} \\\\\n && var= .DisplayReason ||'
        local PrivateReasonMessage = 'run edit ${var .PrivateReason} \\\\\n && var= .PrivateReason ||'

        local RemoteEvent = IncludedCommandUtil:GetRemote("PersistentBan") :: RemoteEvent

        RemoteEvent.OnClientEvent:Connect(function(...)
            Messages:DisplayHint("Persistent Bans: Please provide an optional Display Ban Message. This will be shown to the banned individual(s). 400 Character Limit.",10)
            Executor:ExecuteCommandWithOrWithoutPrefix(DisplayReasonMessage,Players.LocalPlayer)

            Messages:DisplayHint("Persistent Bans: Please provide an optional Private Ban Message. This will be visible only to user(s) authorized to access :pbans. 950 Character Limit.",10)
            Executor:ExecuteCommandWithOrWithoutPrefix(PrivateReasonMessage,Players.LocalPlayer)

            RemoteEvent:FireServer(...)
        end)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, PlayerNames: {string}, Duration: number, ExpWide: boolean, IncludeAlts: boolean): string?
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))

        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        --Return if persistent bans is the legacy system.
        if Api.CommandData.LegacyPersistentBans then
            return "Overhauled persistent bans disabled within this experience. Please use :pban-legacy."
        end

        --Return if the persistent bans weren't initialized.
        local PersistentBans = Api.CommandData.PersistentBans :: PersistentBans.PersistentBans
        if not PersistentBans:WasInitialized() then
            return "Persistent bans failed to initialize."
        end

        --Resolve the names.
        local Ids = {}
        for _,Name in PlayerNames do
            for _, Id in PersistentBans:ResolveUserIds(Name) do
                table.insert(Ids,Id)
            end
        end

        --Send Request to appropriate client as to provide the reasons for the ban. 
        (Util:GetRemote("PersistentBan") :: RemoteEvent):FireClient(CommandContext.Executor,Ids,Duration,ExpWide,IncludeAlts)  
        return nil
    end,
}