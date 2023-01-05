--[[
TheNexusAvenger

Handles users being authorized.
--]]

local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")

local Authorization = require(script.Parent.Parent:WaitForChild("Common"):WaitForChild("Authorization"))
local Types = require(script.Parent.Parent:WaitForChild("Types"))

local ServerAuthorization = {}
ServerAuthorization.__index = ServerAuthorization
setmetatable(ServerAuthorization, Authorization)



--[[
Creates a server authorization instance.
--]]
function ServerAuthorization.new(Configuration: Types.Configuration, NexusAdminRemotes: Folder): Types.Authorization
    local self = Authorization.new(Configuration)
    setmetatable(self, ServerAuthorization)
    self.GroupService = GroupService
    self.GameId = game.GameId
    self.CreatorId = game.CreatorId

    --Determine the group owner.
    if game.CreatorType == Enum.CreatorType.Group then
        xpcall(function()
            self.GroupGameCreator = self.GroupService:GetGroupInfoAsync(self.CreatorId).Owner.Id
        end, function(ErrorMessage)
            warn("Fetching group owner failed because "..tostring(ErrorMessage))
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

    --Return the object.
    return (self :: any) :: Types.Authorization
end

--[[
Initializes the existing players and connects new players.
--]]
function ServerAuthorization:InitializePlayers(): ()
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
function ServerAuthorization:InitializePlayer(Player: Player): ()
    --Set the admin level based on the default or given admin level.
    local UserId = tostring(Player.UserId)
    local AdminLevel = self.AdminLevels[UserId] or self.Configuration.DefaultAdminLevel
    if self.Configuration.Admins[Player.UserId] then
        AdminLevel = math.max(AdminLevel, self.Configuration.Admins[Player.UserId])
    end

    --Set TheNexusAvenger as a debug admin.
    if Player.UserId == 25691148 then
        AdminLevel = math.max(AdminLevel, 0)
    end

    --Set the admin level based on group id.
    xpcall(function()
        for _, UserGroupInfo in self.GroupService:GetGroupsAsync(Player.UserId) do
            local GroupInfo = self.Configuration.GroupAdminLevels[UserGroupInfo.Id]
            if GroupInfo then
                for Rank, NewAdminLevel in GroupInfo do
                    if UserGroupInfo.Rank >= Rank then
                        AdminLevel = math.max(AdminLevel,NewAdminLevel)
                    end
                end
            end
        end
    end, function(ErrorMessage)
        warn("Getting group info failed because "..ErrorMessage)
    end)

    --Set the admin level to highest one if the user is the owner or in Studio.
    if self.GameId == 0 or self.CreatorId == 0 or Player.UserId == self.CreatorId or Player.UserId == self.GroupGameCreator then
        if self.Configuration then
            for Level, _ in self.Configuration.AdminNames do
                AdminLevel = math.max(tonumber(Level) :: number, AdminLevel)
            end
        end
    end

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
Sets the admin level for a player.
--]]
function ServerAuthorization:SetAdminLevel(Player: Player, AdminLevel: number): ()
    Authorization.SetAdminLevel(self, Player, AdminLevel)
    self.AdminLevelChangedRemote:FireAllClients(Player, self.AdminLevels[tostring(Player.UserId)])
end



return ServerAuthorization