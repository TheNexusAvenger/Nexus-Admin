--Handles users being authorized.
--!strict

local NexusInstance = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))
local Configuration = require(script.Parent:WaitForChild("Configuration"))

local TypedEvent = NexusInstance.TypedEvent

local Authorization = {}
Authorization.__index = Authorization

export type Authorization = {
    Configuration: Configuration.Configuration,
    AdminLevels: {[string]: number},
    AdminLevelChanged: NexusInstance.TypedEvent<Player>,
} & typeof(setmetatable({}, Authorization))



--[[
Creates an authorization instance.
--]]
function Authorization.new(Configuration: Configuration.Configuration): Authorization
    return setmetatable({
        Configuration = Configuration,
        AdminLevels = {},
        AdminLevelChanged = TypedEvent.new() :: any,
    }, Authorization) :: Authorization
end

--[[
Returns the admin level for a player.
--]]
function Authorization.GetAdminLevel(self: Authorization, Player: Player): number
    if self.Configuration then
        return self.AdminLevels[tostring(Player.UserId)] or self.Configuration.DefaultAdminLevel
    else
        return self.AdminLevels[tostring(Player.UserId)] or -1
    end
end

--[[
Returns if the user is authorized.
--]]
function Authorization.IsPlayerAuthorized(self: Authorization, Player: Player, AdminLevel: number): boolean
    return self:GetAdminLevel(Player) >= AdminLevel
end

--[[
Waits for an admin level to be defined.
Returns it when it is initialized.
--]]
function Authorization.YieldForAdminLevel(self: Authorization, Player: Player): number
    while not self.AdminLevels[tostring(Player.UserId)] do
        self.AdminLevelChanged:Wait()
    end
    return self.AdminLevels[tostring(Player.UserId)]
end

--[[
Sets the admin level for a player.
--]]
function Authorization.SetAdminLevel(self: Authorization, Player: Player, AdminLevel: number): ()
    self.AdminLevels[tostring(Player.UserId)] = AdminLevel
    self.AdminLevelChanged:Fire(Player)
end



return Authorization