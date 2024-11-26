--Loads Nexus Admin for the normal deployment.
--!strict

return function(LoaderScript,Configuration)
    --Copy Nexus Admin to ServerScriptService.
    local NexusAdminModule = script:WaitForChild("NexusAdmin")
    NexusAdminModule.Parent = game:GetService("ServerScriptService")

    --Load Nexus admin.
    local NexusAdmin = require(NexusAdminModule) :: any
    NexusAdmin:Load(Configuration)
    NexusAdmin:LoadIncludedCommands()
    NexusAdmin:LoadClientLoader()

    --Load the child scripts.
    if LoaderScript then
        for _, Ins in LoaderScript:GetChildren() do
            if Ins:IsA("ModuleScript") then
                xpcall(function()
                    local _ = require(Ins) :: any
                end, function(Error)
                    warn(`{Ins:GetFullName()} module failed to load because "{Error}"\n{debug.traceback()}`)
                end)
            end
        end
    end
    
    --Print that Nexus Admin has loaded (kept from V.1.X.X).
    print(`[NEXUS ADMIN] Nexus Admin {NexusAdmin.Version} sucessfully loaded.`)

    --Return the API.
    return NexusAdmin
end