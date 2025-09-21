--Stores the state for persistent bans.
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NexusDataStore = require(ReplicatedStorage:WaitForChild("NexusAdminClient"):WaitForChild("Packages"):WaitForChild("NexusDataStore")) :: any
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

local PersistentBans = {}
PersistentBans.__index = PersistentBans

local StaticInstance = nil

export type PersistentBans = {
    Initialized: boolean,
    InitializationStarted: boolean,
    Enabled: boolean,
    Api: Types.NexusAdminApiServer,
    PlayerUpdateEvents: {[Player]: RBXScriptConnection},
    LogsDataStore: any,
} & typeof(setmetatable({}, PersistentBans))

--[[
Creates a persistent bans object.
--]]
function PersistentBans.new(Api: Types.NexusAdminApiServer): PersistentBans
    return setmetatable({
        InitializationStarted = false,
        Initialized = false,
        Api = Api,
        Enabled = true,
    }, PersistentBans) :: PersistentBans
end

--[[
Returns a static instance of the persistent bans.
--]]
function PersistentBans.GetInstance(Api: Types.NexusAdminApiServer): PersistentBans
    if not StaticInstance then
        StaticInstance = PersistentBans.new(Api)

        StaticInstance:Initialize()
    end
    while not StaticInstance.Initialized do
        task.wait()
    end
    return StaticInstance
end

--[[
Initializes the bans.
--]]
function PersistentBans.Initialize(self: PersistentBans): ()
    if self.InitializationStarted then return end
    self.InitializationStarted = true

    if RunService:IsStudio() then
        self.Initialized = true
        self.Enabled = false
        return
    end

    --Players.BanningEnabled is unreadable, this is a workaround.
    local Worked, ErrorMessage = pcall(function()
        Players:GetBanHistoryAsync(1)
    end)
    if not Worked and ErrorMessage == "GetBanHistoryAsync is disabled due to Players:BanningEnabled being set to false" then
        warn(`Unable to use Roblox Ban Api as Players.BanningEnabled is set to false. Nexus Admin Persistent Bans disabled.`)
        self.Initialized = true
        self.Enabled = false
        return
    elseif not Worked then
        self.Initialized = true
        warn(`Persistent Bans failed to load because {ErrorMessage}`)
        return
    end

    xpcall(function()
        self.LogsDataStore = NexusDataStore:GetDataStore("NexusAdmin_Persistence", "PersistentBan_Logs")
    end, function(ErrorMessage)
        warn(`Failed to get persistent ban logs because {ErrorMessage}`)
    end)

    self:TransferLegacy()

    self.Initialized = true
end

--[[
Transfer legacy persistent bans
--]]
function PersistentBans.TransferLegacy(self: PersistentBans): ()
    --Get the DataStore.
    local BansDataStore

    local Worked, ErrorMessage = pcall(function()
        BansDataStore = NexusDataStore:GetDataStore("NexusAdmin_Persistence", "PercistentBans")
    end)
    if not Worked then
        warn(`Failed to get persistent bans because {ErrorMessage}`)
        warn(`Persistent bans legacy transfer aborted`)
        return
    end

    --Call :BanId individually for each legacy ban, assuming no two bans have the same reason.
    for _, Id in BansDataStore:ListKeys() do
        local Reason = BansDataStore:Get(Id)
        local Worked, ErrorMessage = self:BanId(tonumber(Id) :: number, Reason, -2, "Nexus Admin Legacy Persistent Ban Transfer")
        if Worked then
            --Remove the legacy ban, so next transfer does not apply another ban.
            BansDataStore:Set(Id, nil)
        end
    end
end

--[[
Returns if the bans initialized correctly.
--]]
function PersistentBans.WasInitialized(self: PersistentBans): boolean
    return self.Initialized and self.Enabled
end

--[[
Attempts to resolve the user ids for the given name.
--]]
function PersistentBans.ResolveUserIds(self: PersistentBans, Name: string): {number}
    --Add the ids from the players.
    local Ids = {}
    for _,Player in Players:GetPlayers() do
        if string.find(string.lower(Player.Name), string.lower(Name)) then
            table.insert(Ids, Player.UserId)
        end
    end

    --Add the user id from the name if no players match.
    if #Ids == 0 then
        if tonumber(Name) then
            table.insert(Ids, tonumber(Name))
        else
            pcall(function()
                table.insert(Ids, Players:GetUserIdFromNameAsync(Name))
            end)
        end
    end

    --Return the ids.
    return Ids
end

--[[
Bans a user id.

Preserved for backwards compatibility and minimal script changes.
--]]
function PersistentBans.BanId(self: PersistentBans, UserId: number, Message: string | boolean, ModeratorId: number?, ModeratorName: string?): (boolean, string, {number}, {number})
    return self:BanIds({
        UserIds = {UserId},
        Duration = -1,
        DisplayReason = type(Message) == "string" and Message or "No ban reason specified.",
        PrivateReason = type(Message) == "string" and Message or "No ban reason specified.",
        ExcludeAltAccounts = false,
        ApplyToUniverse = true
    }, ModeratorId or 0, ModeratorName or "Nexus Admin")
end

--[[
Bans user ids.
--]]
function PersistentBans.BanIds(self: PersistentBans, Config: BanConfigType, ModeratorId: number?, ModeratorName: string?): (boolean, string, {number}, {number})
    local CanBan, Immune = self:FilterIds(Config.UserIds, ModeratorId or 0)
    Config.UserIds = CanBan
    if #Config.UserIds == 0 then
        return false, "No affected UserIds", CanBan, Immune
    end
    self:Log(Config, ModeratorId, ModeratorName)
    local Success, ErrorMessage = pcall(function()
        Players:BanAsync(Config)
    end)

    return Success, ErrorMessage or "User Ids banned.", CanBan, Immune
end

--[[
Unbans a user id.

Preserved for backwards compatibility and minimal script changes.
--]]
function PersistentBans.UnbanId(self: PersistentBans, UserId: number, ModeratorId: number?, ModeratorName: string?)
    return self:UnbanIds({
        UserIds = {UserId},
        ApplyToUniverse = true,
    }, ModeratorId or 0, ModeratorName or "Nexus Admin")
end


--[[
Unbans user ids
--]]
function PersistentBans.UnbanIds(self: PersistentBans, Config: UnbanConfigType, ModeratorId: number?, ModeratorName: string?): (boolean, string?)
    self:Log(Config, ModeratorId, ModeratorName)
    return pcall(function()
        Players:UnbanAsync(Config)
    end)
end

--[[
Logs an action
--]]
function PersistentBans.Log(self: PersistentBans, Config: BanConfigType | UnbanConfigType, ModeratorId: number?, ModeratorName : string?)
    if self.LogsDataStore then
        task.spawn(function()
            if (Config :: BanConfigType).DisplayReason then
                --Silences the type error below, despite the if statement requiring Config to be of type BanConfigType for this line to even run in the first place.
                --Nice type checking roblox.
                local Config = Config :: BanConfigType 
                self.LogsDataStore:Update("PersistentBanActionsLog", function(OldLogs)
                    OldLogs = OldLogs or {}
                    table.insert(OldLogs, {
                        Time = os.time(),
                        Id = ModeratorId or 0,
                        Name = ModeratorName or "Nexus Admin",
                        Action = 0,
                        EffectedUserIds = Config.UserIds,
                        Duration = math.max(-1, Config.Duration),
                        ExperienceWide = Config.ApplyToUniverse,
                        IncludeAlts = not Config.ExcludeAltAccounts
                    })
                    return OldLogs
                end)
            else
                self.LogsDataStore:Update("PersistentBanActionsLog", function(OldLogs)
                    OldLogs = OldLogs
                    table.insert(OldLogs, {
                        Time = os.time(),
                        Id = ModeratorId or 0,
                        Name = ModeratorName or "Nexus Admin",
                        Action = 1,
                        EffectedUserIds = Config.UserIds,
                        ExperienceWide = Config.ApplyToUniverse,
                    })
                    return OldLogs
                end)
            end
        end)
    end
end

--[[
Returns all persistent ban logs
--]]
function PersistentBans.GetLogs(self: PersistentBans)
    if self.LogsDataStore then
        return self.LogsDataStore:Get("PersistentBanActionsLog") or {}
    else
        return {"Persistent Ban Logs failed to initialize."}
    end
end

--[[
Try and filter out Persistent Ban Immune UserIds of both in server players and out of server players.
--]]
function PersistentBans.FilterIds(self: PersistentBans, Ids: {number}, ModeratorId: number): ({number}, {number})
    local Filtered = {}
    local Immune = {}
    local PersistentBanImmuneLevel = self.Api.Configuration.CommandConfigurations.PersistentBanImmuneLevel
    local AdminLevel = PersistentBanImmuneLevel
    if ModeratorId > 0 then
        AdminLevel = self.Api.Authorization:GetAdminLevel(Players:GetPlayerByUserId(ModeratorId))
    end
    for i, Id in Ids do
        if self.Api.Authorization:EvaluateAdminLevelAsync(Id) >= math.min(PersistentBanImmuneLevel, AdminLevel) then
            table.insert(Immune, Id)
        else
            table.insert(Filtered, Id)
        end
    end
    return Filtered, Immune
end
return PersistentBans