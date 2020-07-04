--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()
Command.PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans")).GetStaticInstance()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("pbans","PersistentCommands","Displays a list of all permanent bans.")

    --[[
    Returns the name for the user id.
    --]]
    local UserNameCache = {}
    local function GetUserName(UserId)
        --Add the name to the cache.
        if not UserNameCache[UserId] then
            UserNameCache[UserId] = "[NAME FETCH FAILED]"
            pcall(function()
                UserNameCache[UserId] = self.Players:GetNameFromUserIdAsync(UserId)
            end)
        end

        --Return the cached username.
        return UserNameCache[UserId]
    end
    
    --Create the remote function.
    local GetPersistentBansRemoteFunction = Instance.new("RemoteFunction")
    GetPersistentBansRemoteFunction.Name = "GetPersistentBans"
    GetPersistentBansRemoteFunction.Parent = self.API.EventContainer

    function GetPersistentBansRemoteFunction.OnServerInvoke(Player)
        if self.API.Authorization:IsPlayerAuthorized(Player,self.AdminLevel) then
            if self.PersistentBans:WasInitialized() then
                --Create the messages list.
                local BannedPlayers = {}
                for UserId,Message in pairs(self.PersistentBans.BannedUsers) do
                    if Message == true then
                        table.insert(BannedPlayers,GetUserName(UserId).." ("..tostring(UserId)..")")
                    else
                        table.insert(BannedPlayers,GetUserName(UserId).." ("..tostring(UserId)..") - "..tostring(Message))
                    end
                end

                --Sort and return the messages.
                table.sort(BannedPlayers,function(a,b) return string.lower(a) < string.lower(b) end)
                return BannedPlayers
            else
                return {"Persistent bans failed to initialize"}
            end
        else
            return {"Unauthorized"}
        end
    end

    --Initialize the persistent bans.
    self.PersistentBans:Initialize()
end



return Command