--Handles users being authorized.
--!strict

local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")

local Authorization = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("Authorization"))
local Configuration = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("Configuration"))

local ServerAuthorization = {}
ServerAuthorization.__index = ServerAuthorization
setmetatable(ServerAuthorization, Authorization)

export type ServerAuthorization = {
    GroupService: GroupService,
    GameId: number,
    CreatorId: number,
    GroupGameCreator: number?,
    GetAdminLevels: RemoteFunction,
    AdminLevelChangedRemote: RemoteEvent,
    GroupAdminLevelCache: {[number]: number}
} & typeof(setmetatable({}, ServerAuthorization)) & Authorization.Authorization



--[[
Creates a server authorization instance.
--]]
function ServerAuthorization.new(Configuration: Configuration.Configuration, NexusAdminRemotes: Folder): ServerAuthorization
    local self = setmetatable(Authorization.new(Configuration), ServerAuthorization) :: ServerAuthorization
    self.GroupService = GroupService
    self.GameId = game.GameId
    self.CreatorId = game.CreatorId
    
    --Store the highest AdminLevel of a UserId based on Groups alone.
    self.GroupAdminLevelCache = {}

    --Determine the group owner.
    if game.CreatorType == Enum.CreatorType.Group then
        xpcall(function()
            self.GroupGameCreator = self.GroupService:GetGroupInfoAsync(self.CreatorId).Owner.Id
        end, function(ErrorMessage)
            warn(`Fetching group owner failed because {ErrorMessage}`)
        end)
    end

    --Create the remote objects.
    local AuthorizationEvents = Instance.new("Folder")
    AuthorizationEvents.Name = "AuthorizationEvents"
    AuthorizationEvents.Parent = NexusAdminRemotes

    local GetAdminLevels = Instance.new("RemoteFunction")
    GetAdminLevels.Name = "GetAdminLevels"
    GetAdminLevels.Parent = AuthorizationEvents
    self.GetAdminLevels = GetAdminLevels

    local AdminLevelChanged = Instance.new("RemoteEvent")
    AdminLevelChanged.Name = "AdminLevelChanged"
    AdminLevelChanged.Parent = AuthorizationEvents
    self.AdminLevelChangedRemote = AdminLevelChanged

    --Connect the remote objects.
    function GetAdminLevels.OnServerInvoke()
        return self.AdminLevels
    end
    
    --Initialize flushing GroupAdminLevelCache every 30 minutes.
    task.spawn(function()
        while task.wait(30 * 60) do
            self:FlushGroupAdminLevelCache()
        end
    end)

    --Return the object.
    return self
end

--[[
Initializes the existing players and connects new players.
--]]
function ServerAuthorization.InitializePlayers(self: ServerAuthorization): ()
    --Connect new players.
    Players.PlayerAdded:Connect(function(Player: Player): ()
        self:InitializePlayer(Player)
    end)

    --Initialize the existing players.
    for _, Player in Players:GetPlayers() do
        task.spawn(function()
            self:InitializePlayer(Player)
        end)
    end
end

--[[
Initializes a player.
--]]
function ServerAuthorization.InitializePlayer(self: ServerAuthorization, Player: Player): ()
    if self.GroupAdminLevelCache[Player.UserId] then
        self.GroupAdminLevelCache[Player.UserId] = nil
    end
    
    --Set the admin level based on the default or given admin level.
    local UserId = tostring(Player.UserId)
    local AdminLevel = self:EvaluateAdminLevelAsync(Player.UserId)

    --Send the admin level change.
    if self.AdminLevels[UserId] then
        self.AdminLevels[UserId] = math.max(AdminLevel, self.AdminLevels[UserId])
    else
        self.AdminLevels[UserId] = AdminLevel
    end
    self.AdminLevelChangedRemote:FireAllClients(Player, AdminLevel)
    self.AdminLevelChanged:Fire(Player)
end

--[[
Evaluates the AdminLevel of a UserId.
--]]
function ServerAuthorization.EvaluateAdminLevelAsync(self: ServerAuthorization, UserId: number): number
    local UserId_String = tostring(UserId)
    local AdminLevel = self.AdminLevels[UserId_String] or self.Configuration.DefaultAdminLevel
    if self.Configuration.Admins[UserId] then
        AdminLevel = math.max(AdminLevel, self.Configuration.Admins[UserId])
    end

    --Set the admin level based on group id.
    AdminLevel = math.max(AdminLevel, self:EvaluateGroupAdminLevelAsync(UserId))

    --Set the admin level to highest one if the user is the owner or in Studio.
    if self.GameId == 0 or self.CreatorId == 0 or UserId == self.CreatorId or UserId == self.GroupGameCreator then
        if self.Configuration then
            for Level, _ in self.Configuration.AdminNames do
                AdminLevel = math.max(tonumber(Level) :: number, AdminLevel)
            end
        end
    end
    
    return AdminLevel
end

--[[
Evaluates the AdminLevel of a UserId based on groups alone and store said value.
--]]
function ServerAuthorization.EvaluateGroupAdminLevelAsync(self: ServerAuthorization, UserId: number): number
    if self.GroupAdminLevelCache[UserId] then
        return self.GroupAdminLevelCache[UserId]
    end
    --Make the number unreasonably low just so the first math.max doesn't get fed a nil value.
    local AdminLevel = -math.huge
    xpcall(function()
        for _, UserGroupInfo in self.GroupService:GetGroupsAsync(UserId) do
            local GroupInfo = self.Configuration.GroupAdminLevels[UserGroupInfo.Id]
            if GroupInfo then
                for Rank, NewAdminLevel in GroupInfo do
                    if UserGroupInfo.Rank >= Rank then
                        AdminLevel = math.max(AdminLevel, NewAdminLevel)
                    end
                end
            end
        end
    end, function(ErrorMessage)
        warn(`Getting group info failed because {ErrorMessage}`)
    end)
    
    self.GroupAdminLevelCache[UserId] = AdminLevel
    
    return AdminLevel
end

--[[
Clears the GroupAdminLevelCache of all indexes and values.
--]]
function ServerAuthorization.FlushGroupAdminLevelCache(self: ServerAuthorization)
    table.clear(self.GroupAdminLevelCache)
end

--[[
Sets the admin level for a player.
--]]
function ServerAuthorization.SetAdminLevel(self: ServerAuthorization, Player: Player, AdminLevel: number): ()
    Authorization.SetAdminLevel(self, Player, AdminLevel)
    self.AdminLevelChangedRemote:FireAllClients(Player, self.AdminLevels[tostring(Player.UserId)])
end



return ServerAuthorization