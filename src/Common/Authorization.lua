--[[
TheNexusAvenger

Handles users being authorized.
--]]
--!strict

local NexusEvent = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("Event"):WaitForChild("NexusEvent"))
local Types = require(script.Parent.Parent:WaitForChild("Types"))

local Authorization = {}
Authorization.__index = Authorization



--[[
Creates an authorization instance.
--]]
function Authorization.new(Configuration: Types.Configuration): Types.Authorization
    return (setmetatable({
        Configuration = Configuration,
        AdminLevels = {},
        AdminLevelChanged = NexusEvent.new(),
    }, Authorization) :: any) :: Types.Authorization
end

--[[
Returns the admin level for a player.
--]]
function Authorization:GetAdminLevel(Player: Player): number
    if self.Configuration then
        return self.AdminLevels[tostring(Player.UserId)] or self.Configuration.DefaultAdminLevel
    else
        return self.AdminLevels[tostring(Player.UserId)] or -1
    end
end

--[[
Returns if the user is authorized.
--]]
function Authorization:IsPlayerAuthorized(Player: Player, AdminLevel: number): boolean
    return self:GetAdminLevel(Player) >= AdminLevel
end

--[[
Waits for an admin level to be defined.
Returns it when it is initialized.
--]]
function Authorization:YieldForAdminLevel(Player: Player): number
    while not self.AdminLevels[tostring(Player.UserId)] do
        self.AdminLevelChanged:Wait()
    end
    return self.AdminLevels[tostring(Player.UserId)]
end

--[[
Sets the admin level for a player.
--]]
function Authorization:SetAdminLevel(Player: Player, AdminLevel: number): ()
    self.AdminLevels[tostring(Player.UserId)] = AdminLevel
    self.AdminLevelChanged:Fire(Player)
end



return Authorization