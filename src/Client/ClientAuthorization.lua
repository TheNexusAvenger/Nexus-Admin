--[[
TheNexusAvenger

Handles users being authorized on the client.
--]]

local Authorization = require(script.Parent:WaitForChild("Common"):WaitForChild("Authorization"))

local ClientAuthorization = Authorization:Extend()
ClientAuthorization:SetClassName("ClientAuthorization")



--[[
Creates a client authorization instance.
--]]
function ClientAuthorization:__new(Configuration,NexusAdminRemotes)
    self:InitializeSuper(Configuration)

    local AuthorizationEvents = NexusAdminRemotes:WaitForChild("AuthorizationEvents")
    self.AdminLevels = AuthorizationEvents:WaitForChild("GetAdminLevels"):InvokeServer()

    --Connect the remote objects.
    AuthorizationEvents:WaitForChild("AdminLevelChanged").OnClientEvent:Connect(function(Player,AdminLevel)
        self:SetAdminLevel(Player,AdminLevel)
    end)
end



return ClientAuthorization