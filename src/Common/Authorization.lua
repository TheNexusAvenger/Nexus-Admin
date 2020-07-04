--[[
TheNexusAvenger

Handles users being authorized.
--]]

local NexusObject = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))
local NexusEventCreator = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("Event"):WaitForChild("NexusEventCreator"))

local Authorization = NexusObject:Extend()
Authorization:SetClassName("Authorization")



--[[
Creates an authorization instance.
--]]
function Authorization:__new(Configuration)
    self:InitializeSuper()

    self.Configuration = Configuration
    self.AdminLevels = {}
    self.AdminLevelChanged = NexusEventCreator:CreateEvent()
end

--[[
Returns the admin level for a player.
--]]
function Authorization:GetAdminLevel(Player)
    if self.Configuration then
        return self.AdminLevels[tostring(Player.UserId)] or self.Configuration.DefaultAdminLevel
    else
        return self.AdminLevels[tostring(Player.UserId)] or -1
    end
end

--[[
Returns if the user is authorized.
--]]
function Authorization:IsPlayerAuthorized(Player,AdminLevel)
    return self:GetAdminLevel(Player) >= AdminLevel
end

--[[
Waits for an admin level to be defined.
Returns it when it is initialized.
--]]
function Authorization:YieldForAdminLevel(Player)
    while not self.AdminLevels[tostring(Player.UserId)] do
        self.AdminLevelChanged:Wait()
    end
    return self.AdminLevels[tostring(Player.UserId)]
end

--[[
Sets the admin level for a player.
--]]
function Authorization:SetAdminLevel(Player,AdminLevel)
    self.AdminLevels[tostring(Player.UserId)] = AdminLevel
    self.AdminLevelChanged:Fire(Player)
end



return Authorization