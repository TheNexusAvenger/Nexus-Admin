--[[
TheNexusAvenger

Stores and parses the configuration.
--]]
--!strict

local Types = require(script.Parent.Parent:WaitForChild("Types"))

local Configuration = {}
Configuration.__index = Configuration



--[[
Creates the configuration.
--]]
function Configuration.new(ConfigurationTable: {[string]: any}): Types.Configuration
    ConfigurationTable = ConfigurationTable or {}
    local self = {}
    setmetatable(self, Configuration)

    --Store the values.
    self.Version = "Version 2.7.1"
    self.VersionNumberId = 2.7
    self.CmdrVersion = "Version 1.10.0"
    self.RawConfiguration = ConfigurationTable
    self.CommandPrefix = ConfigurationTable.CommandPrefix or ":"
    self.ActivationKeys = ConfigurationTable.ActivationKeys or {Enum.KeyCode.BackSlash}
    self.DefaultAdminLevel = ConfigurationTable.DefaultAdminLevel or -1
    self.AdministrativeLevel = ConfigurationTable.AdministrativeLevel or 1
    self.BuildUtilityLevel = ConfigurationTable.BuildUtilityLevel or 1
    self.BasicCommandsLevel = ConfigurationTable.BasicCommandsLevel or 1
    self.UsefulFunCommandsLevel = ConfigurationTable.UsefulFunCommandsLevel or 2
    self.FunCommandsLevel = ConfigurationTable.FunCommandsLevel or 3
    self.PersistentCommandsLevel = ConfigurationTable.PersistentCommandsLevel or ConfigurationTable.PersistentCommands or 4
    self.Admins = ConfigurationTable.Admins or {}
    self.AdminNames = ConfigurationTable.AdminNames or {
        [-1] = "Non-Admin", --Basic commands, like !help and !quote
        [0] = "Debug Admin", --Only debug commands
        [1] = "Moderator", --Some commands, can't kick, no "fun" commands
        [2] = "Admin", --Most commands, can't ban or shutdown
        [3] = "Super Admin",--All commands, can be kicked by full admin
        [4] = "Owner Admin", --All commands, except :admin
        [5] = "Creator Admin", --All commands, including :admin
    }
    self.GroupAdminLevels = ConfigurationTable.GroupAdminLevels or {}
    self.BannedUsers = ConfigurationTable.BannedUsers or {}
    self.CommandLevelOverrides = ConfigurationTable.CommandLevelOverrides or {}
    self.FeatureFlagOverrides = ConfigurationTable.FeatureFlagOverrides or {}

    --Correct the administrative commands (V.2.0.0 and newer).
    if ConfigurationTable.CommandLevelOverrides and not ConfigurationTable.CommandLevelOverrides.Administrative then
        ConfigurationTable.CommandLevelOverrides.Administrative = {
            admin = 5,
            unadmin = 5,
            ban = 3,
            unban = 3,
            kick = 2,
            slock = 2,
            keybind = -1,
            unkeybind = -1,
            keybinds = -1,
            alias = -1,
            cmds = -1,
            cmdbar = -1,
            debug = 0,
            logs = 0,
            admins = 0,
            bans = nil,
            usage = -1,
            featureflag = nil,
        }
    end

    --Add F2 to the ActivationKeys if F2 is not defined but BackSlash is.
    local ActivationKeysMap = {}
    for _, Key in self.ActivationKeys do
        ActivationKeysMap[Key] = true
    end
    if not ActivationKeysMap[Enum.KeyCode.F2] and ActivationKeysMap[Enum.KeyCode.BackSlash] then
        table.insert(self.ActivationKeys, Enum.KeyCode.F2)
    end

    --Return the configuration.
    return (self :: any) :: Types.Configuration
end

--[[
Raw configuration used table. This is intended for custom
configuration entries used for custom deployments.
--]]
function Configuration:GetRaw()
    return self.RawConfiguration
end

--[[
Returns the admin level to use for an integrated command.
--]]
function Configuration:GetCommandAdminLevel(Category: string, Command: string): number
    --Get the category default.
    local CategoryDefault = self[Category.."Level"] :: number
    if not CategoryDefault then
        error("\""..tostring(Category).."\" is not a category supported by the configuration.")
    end

    --Return the override or the default.
    if self.CommandLevelOverrides[Category] and self.CommandLevelOverrides[Category][Command] then
        return self.CommandLevelOverrides[Category][Command]
    else
        return CategoryDefault
    end
end



return (Configuration :: any) :: Types.Configuration