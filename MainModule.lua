--[[
TheNexusAvenger

Loads Nexus Admin for the normal deployment.
--]]

return function(LoaderScript,Configuration)
    --Copy Nexus Admin to ServerScriptService.
    local NexusAdminModule = script:WaitForChild("NexusAdmin")
    NexusAdminModule.Parent = game:GetService("ServerScriptService")

    --Load Nexus admin.
    local NexusAdmin = require(NexusAdminModule)
    NexusAdmin:Load(Configuration)
    NexusAdmin:LoadIncludedCommands()
    NexusAdmin:LoadClientLoader()

    --Load the child scripts.
    if LoaderScript then
        for _,Ins in pairs(LoaderScript:GetChildren()) do
            if Ins:IsA("ModuleScript") then
                xpcall(function()
                    require(Ins)
                end, function(Error)
                    warn(tostring(Ins:GetFullName()).." module failed to load because \""..tostring(Error).."\"")
                end)
            end
        end
    end
    
    --Print that Nexus Admin has loaded (kept from V.1.X.X).
    print("[NEXUS ADMIN] Nexus Admin "..tostring(NexusAdmin.Version).." sucessfully loaded.")

    --Return the API.
    return NexusAdmin
end