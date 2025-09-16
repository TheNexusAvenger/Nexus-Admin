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

        --Try and filter out Persistent Ban Immune UserIds of both in server players and out of server players.
        local function FilterIds(Ids: {number}, Executor: Player)
            local Filtered = {}
            local PersistentBanImmuneLevel = Api.Configuration.CommandConfigurations.PersistentBanImmuneLevel
            for i, Id in Ids do
                if Api.Authorization:EvaluateAdminLevelAsync(Id) >= math.min(PersistentBanImmuneLevel,Api.Authorization:GetAdminLevel(Executor)) then
                    continue
                else
                    table.insert(Filtered,Id)
                end
            end
            return Filtered
        end

        local RemoteEvent = (IncludedCommandUtil:CreateRemote("RemoteEvent","PersistentBan") :: RemoteEvent)

        RemoteEvent.OnServerEvent:Connect(function(Player, Ids: {number}, Duration: number, ExpWide: boolean, IncludeAlts: boolean)
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

        --Return if the persistent bans weren't initialized.
        local PersistentBans = Api.CommandData.PersistentBans :: PersistentBans.PersistentBans
        if not PersistentBans:WasInitialized() then
            if Api.CommandData.PersistentBans.Disabled then
                return "RobloxBanAPI is disabled within this experience."
            else
                return "Persistent bans failed to initialize."
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
        (Util:GetRemote("PersistentBan") :: RemoteEvent):FireClient(CommandContext.Executor, Ids, Duration, ExpWide, IncludeAlts)  
        return nil
    end,
}