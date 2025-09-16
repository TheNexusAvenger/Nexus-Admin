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
    Disabled: boolean,
    Api: Types.NexusAdminApiServer,
    PlayerUpdateEvents: {[Player]: RBXScriptConnection},
    BansDataStore: any,
} & typeof(setmetatable({}, PersistentBans))

--[[
Creates a persistent bans object.
--]]
function PersistentBans.new(Api: Types.NexusAdminApiServer): PersistentBans
    return setmetatable({
        InitializationStarted = false,
        Initialized = false,
        Api = Api,
        Disabled = false,
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
        print("NexusAdmin PersistentBans disabled in studio.")
        self.Initialized = true
        self.Disabled = true
        return
    end

    --Players.BanningEnabled is unreadable, this is a workaround.
    local Worked, ErrorMessage = pcall(function()
        Players:GetBanHistoryAsync(1)
    end)
    if not Worked and ErrorMessage == "GetBanHistoryAsync is disabled due to Players:BanningEnabled being set to false" then
        warn(`Unable to use RobloxBanApi as Players.BanningEnabled is set to false. Persistent bans disabled.`)
        self.Initialized = true
        self.Disabled = true
        return
    elseif not Worked then
        self.Initialized = true
        warn(`Persistent Bans failed to load because {ErrorMessage}`)
        return
    end


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
    for _,Id in BansDataStore:ListKeys() do
        local Reason = BansDataStore:Get(Id)
        local Worked, ErrorMessage = self:BanId(tonumber(Id),Reason,-2,"NexusAdmin-Legacy pban transfer")
        if Worked then
            --Remove the legacy ban, so next transfer does not apply another ban.
            BansDataStore:Set(Id,nil)
        end
    end
end
--[[
Returns if the bans initialized correctly.
--]]
function PersistentBans.WasInitialized(self: PersistentBans): boolean
    return self.Initialized and not self.Disabled
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
function PersistentBans.BanId(self: PersistentBans, UserId: number, Message: string | boolean, ModeratorId: number?, ModeratorName: string?): (boolean, string?)
    return self:BanIds({
        UserIds = {UserId},
        Duration = -1,
        DisplayReason = type(Message) == "string" and Message or "No ban reason specified.",
        PrivateReason = type(Message) == "string" and Message or "No ban reason specified.",
        ExcludeAltAccounts = false,
        ApplyToUniverse = true
    }, ModeratorId or 0, ModeratorName or "NexusAdmin")
end

--[[
Bans user ids.
--]]
function PersistentBans.BanIds(self: PersistentBans, Config: BanConfigType, ModeratorId: number?, ModeratorName: string?): (boolean, string?)
    local Api = self.Api
    if Api.CommandData.PersistentBanLogsDataStore then
        task.spawn(function()
            Api.CommandData.PersistentBanLogsDataStore:Update("PersistentBanActionsLog", function(OldLogs)
                OldLogs = OldLogs or {}
                table.insert(OldLogs, {
                    Time = os.time(),
                    Id = ModeratorId or 0,
                    Name = ModeratorName or "NexusAdmin",
                    Action = 0,
                    EffectedUserIds = Config.UserIds,
                    Duration = math.max(-1,Config.Duration),
                    ExpWide = Config.ApplyToUniverse,
                    IncludeAlts = not Config.ExcludeAltAccounts
                })
                return OldLogs
            end)
        end)
    end
    return pcall(function()
        Players:BanAsync(Config)
    end)
end

--[[
Unbans a user id.

Preserved for backwards compatibility and minimal script changes.
--]]
function PersistentBans.UnbanId(self: PersistentBans, UserId: number, ModeratorId: number?, ModeratorName: string?)
    return self:UnbanIds({
        UserIds = {UserId},
        ApplyToUniverse = true,
    },ModeratorId or 0, ModeratorName or "NexusAdmin")
end

function PersistentBans.UnbanIds(self: PersistentBans, Config: UnbanConfigType, ModeratorId: number?, ModeratorName: string?): (boolean, string?)
    local Api = self.Api
    if Api.CommandData.PersistentBanLogsDataStore then
        task.spawn(function()
            Api.CommandData.PersistentBanLogsDataStore:Update("PersistentBanActionsLog", function(OldLogs)
                OldLogs = OldLogs
                table.insert(OldLogs, {
                    Time = os.time(),
                    Id = ModeratorId or 0,
                    Name = ModeratorName or "NexusAdmin",
                    Action = 1,
                    EffectedUserIds = Config.UserIds,
                    ExpWide = Config.ApplyToUniverse,
                })
                return OldLogs
            end)
        end)
    end
    return pcall(function()
        Players:UnbanAsync(Config)
    end)
end


return PersistentBans
