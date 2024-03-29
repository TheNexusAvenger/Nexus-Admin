--[[
TheNexusAvenger

Handles users being authorized on the client.
--]]
--!strict

local Types = require(script.Parent:WaitForChild("Types"))
local Authorization = require(script.Parent:WaitForChild("Common"):WaitForChild("Authorization")) :: Types.Authorization

local ClientAuthorization = {}
ClientAuthorization.__index = ClientAuthorization
setmetatable(ClientAuthorization, Authorization)



--[[
Creates a client authorization instance.
--]]
function ClientAuthorization.new(Configuration: Types.Configuration, NexusAdminRemotes: Folder): Types.Authorization
    local self = Authorization.new(Configuration) :: Types.Authorization & {AdminLevels: {[string]: number}}
    setmetatable(self, ClientAuthorization)

    local AuthorizationEvents = NexusAdminRemotes:WaitForChild("AuthorizationEvents") :: Folder
    self.AdminLevels = (AuthorizationEvents:WaitForChild("GetAdminLevels") :: RemoteFunction):InvokeServer();

    --Connect the remote objects.
    (AuthorizationEvents:WaitForChild("AdminLevelChanged") :: RemoteEvent).OnClientEvent:Connect(function(Player: Player, AdminLevel: number): ()
        self:SetAdminLevel(Player, AdminLevel)
    end)
    return (self :: any) :: Types.Authorization
end



return ClientAuthorization