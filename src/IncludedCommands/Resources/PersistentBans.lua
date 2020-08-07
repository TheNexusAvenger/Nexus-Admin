--[[
TheNexusAvenger

Stores the state for persistent bans.
--]]

local NexusObject = require(script.Parent.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))

local PersistentBans = NexusObject:Extend()
PersistentBans:SetClassName("PersistentBans")
PersistentBans.Players = game:GetService("Players")
PersistentBans.DataStoreService = game:GetService("DataStoreService")
PersistentBans.MessagingService = game:GetService("MessagingService")

local StaticInstance



--[[
Creates the persistent bans state.
--]]
function PersistentBans:__new()
    self:InitializeSuper()

    --Initialize the state.
    self.API = _G.GetNexusAdminServerAPI()
    self.AttemptedInitialization = false
    self.Initialized = false
    self.BannedUsers = {}
    self.UnpushedChanges = {}
end

--[[
Returns the static instance.
--]]
function PersistentBans.GetStaticInstance()
    if not StaticInstance then
        StaticInstance = PersistentBans.new()
    end
    return StaticInstance
end

--[[
Initializes the bans.
--]]
function PersistentBans:Initialize()
    if not self.AttemptedInitialization then
        self.AttemptedInitialization = true

        --Get the data store.
        local Worked,DataStore = pcall(function()
            return self.DataStoreService:GetDataStore("NexusAdmin_Persistence")
        end)
        if not Worked then
            warn("Getting DataStore failed because "..tostring(DataStore))
        else
            self.DataStore = DataStore
        end

        --Fetch the bans.
        local Worked,Return = pcall(function()
            self:FetchBannedPlayers()
        end)
        if not Worked then
            warn("Fetching bans failed because "..tostring(Return))
            return
        end

        --Connect kicking players.
        self.Players.PlayerAdded:Connect(function(Player)
            self:KickPlayer(Player)
        end)
        for _,Player in pairs(self.Players:GetPlayers()) do
            self:KickPlayer(Player)
        end

        --Connect the messaging service.
        local Worked,Return = pcall(function()
            self.MessagingService:SubscribeAsync("NexusAdminPersistentBansChanged",function(Data)
                self:FetchBannedPlayers()
            end)
        end)
        if not Worked then
            warn("Connecting to messaging service for persistent ban changes failed because "..tostring(Return))
        end

        --Set the system as initialized.
        self.Initialized = true
    end
end

--[[
Returns if the persistent bans were initialized.
--]]
function PersistentBans:WasInitialized()
    return self.Initialized
end

--[[
Kicks a player if they are banned.
--]]
function PersistentBans:KickPlayer(Player)
    coroutine.wrap(function()
        --Return if the player is an admin.
        self.API.Authorization:YieldForAdminLevel(Player)
        if self.API.Authorization:IsPlayerAuthorized(Player,0) then
            return
        end

        --Kick the player.
        if self.BannedUsers then
            if self.BannedUsers[tostring(Player.UserId)] == true then
                Player:Kick()
            elseif self.BannedUsers[tostring(Player.UserId)] then
                Player:Kick(self.BannedUsers[tostring(Player.UserId)])
            end
        end
    end)()
end

--[[
Attempts to resolve the user ids for the given name.
--]]
function PersistentBans:ResolveUserIds(Name)
    --Add the ids from the players.
    local Ids = {}
    for _,Player in pairs(self.Players:GetPlayers()) do
        if string.find(string.lower(Player.Name),string.lower(Name)) then
            table.insert(Ids,Player.UserId)
        end
    end

    --Add the user id from the name if no players match.
    if #Ids == 0 then
        if tonumber(Name) then
            table.insert(Ids,tonumber(Name))
        else
            pcall(function()
                table.insert(Ids,self.Players:GetUserIdFromNameAsync(Name))
            end)
        end
    end

    --Return the ids.
    return Ids
end

--[[
Fetches the banned players.
--]]
function PersistentBans:FetchBannedPlayers()
    self.BannedUsers = self.DataStore:GetAsync("PercistentBans") or {}

    --Kick the banned players.
    for _,Player in pairs(self.Players:GetPlayers()) do
        self:KickPlayer(Player)
    end
end

--[[
Bans a user id.
--]]
function PersistentBans:BanId(UserId,Message)
    Message = Message or true

    --Add the ban.
    self.BannedUsers[tostring(UserId)] = Message
    self.UnpushedChanges[tostring(UserId)] = Message

    --Ban the user if they are in the server.
    local Player = self.Players:GetPlayerByUserId(UserId)
    if Player then
        self:KickPlayer(Player)
    end
end

--[[
Unbans a user id.
--]]
function PersistentBans:UnbanId(UserId)
    --Remove the ban.
    self.BannedUsers[tostring(UserId)] = nil
    self.UnpushedChanges[tostring(UserId)] = false
end

--[[
Updates the banned users.
--]]
function PersistentBans:PushBans()
    --Update the bans.
    self.DataStore:UpdateAsync("PercistentBans",function(ExistingBans)
        ExistingBans = ExistingBans or {}

        --Add the updates.
        for Id,Update in pairs(self.UnpushedChanges) do
            if Update == false then
                ExistingBans[Id] = nil
            else
                ExistingBans[Id] = Update
            end
        end

        --Return the bans.
        return ExistingBans
    end)

    --Reset the unpushed changes.
    self.UnpushedChanges = {}

    --Invoke the event that the bans have changed.
    self.MessagingService:PublishAsync("NexusAdminPersistentBansChanged","")
end



return PersistentBans