--Loads Nexus Admin for the normal deployment.
--!strict

local REQUIRED_LIBRARIES = {
    --Cmdr = "cmdr", --Git submodule used for Cmdr due to outdated release.
    NexusButton = "nexus-button",
    NexusDataStore = "nexus-data-store",
    NexusFeatureFlags = "nexus-feature-flags",
    NexusInstance = "nexus-instance",
    NexusVirtualList = "nexus-virtual-list",
}



return function(LoaderScript,Configuration)
    --Replace the packages when in a Wally package.
    local NexusAdminModule = script:WaitForChild("NexusAdmin")
    local SourcePackages = script.Parent
    if SourcePackages then
        local TargetPackages = NexusAdminModule:WaitForChild("Packages")
        if not TargetPackages:FindFirstChild("_Index") then
            local Index = Instance.new("Folder")
            Index.Name = "_Index"
            Index.Parent = TargetPackages
            
            for PackageName, WallyPackageName in REQUIRED_LIBRARIES do
                local SourceReference = SourcePackages:FindFirstChild(PackageName)
                local SourcePackage = SourcePackages:FindFirstChild(WallyPackageName, true)
                local TargetPackage = TargetPackages:FindFirstChild(PackageName)
                if SourceReference then
                    SourceReference:Clone().Parent = TargetPackages
                end
                if SourcePackage then
                    SourcePackage.Parent:Clone().Parent = Index
                end
                if TargetPackage then
                    TargetPackage:Destroy()
                end
            end
        end
    end

    --Copy Nexus Admin to ServerScriptService.
    --This is meant to provide backward compatibility with the expected final module location.
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