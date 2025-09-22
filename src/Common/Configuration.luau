--Stores and parses the configuration.
--!strict

local DEFAULT_COMMAND_CONFIGURATIONS = {
    --Default Admin Level for Server Lock (slock).
    DefaultServerLockAdminLevel = 0,
} :: {[string]: any}

local Configuration = {}
Configuration.__index = Configuration

export type Configuration = {
    Version: string,
    VersionNumberId: number,
    CmdrVersion: string,
    RawConfiguration: {[string]: any},
    CommandPrefix: string,
    ActivationKeys: {Enum.KeyCode},
    DefaultAdminLevel: number,
    AdministrativeLevel: number,
    BuildUtilityLevel: number,
    BasicCommandsLevel: number,
    UsefulFunCommandsLevel: number,
    FunCommandsLevel: number,
    PersistentCommandsLevel: number,
    Admins: {[number]: number},
    AdminNames: {[number]: string},
    GroupAdminLevels: {[number]: {[number]: number}},
    BannedUsers: {[number]: string | boolean},
    CommandConfigurations: {
        DefaultServerLockAdminLevel: number,
        PersistentBanImmune: number,
        [string]:any,
    },
    CommandLevelOverrides: {[string]: {[string]: number}},
    FeatureFlagOverrides: {[string]: any},
} & typeof(setmetatable({}, Configuration))



--[[
Creates the configuration.
--]]
function Configuration.new(ConfigurationTable: {[string]: any}): Configuration
    ConfigurationTable = ConfigurationTable or {}
    local self = setmetatable({
        Version = "Version 2.10.0",
        VersionNumberId = 2.10,
        CmdrVersion = "Version 1.12.0",
        RawConfiguration = ConfigurationTable,
        CommandPrefix = ConfigurationTable.CommandPrefix or ":",
        ActivationKeys = ConfigurationTable.ActivationKeys or {Enum.KeyCode.BackSlash},
        DefaultAdminLevel = ConfigurationTable.DefaultAdminLevel or -1,
        AdministrativeLevel = ConfigurationTable.AdministrativeLevel or 1,
        BuildUtilityLevel = ConfigurationTable.BuildUtilityLevel or 1,
        BasicCommandsLevel = ConfigurationTable.BasicCommandsLevel or 1,
        UsefulFunCommandsLevel = ConfigurationTable.UsefulFunCommandsLevel or 2,
        FunCommandsLevel = ConfigurationTable.FunCommandsLevel or 3,
        PersistentCommandsLevel = ConfigurationTable.PersistentCommandsLevel or ConfigurationTable.PersistentCommands or 4,
        Admins = ConfigurationTable.Admins or {},
        AdminNames = ConfigurationTable.AdminNames or {
            [-1] = "Non-Admin", --Basic commands, like !help and !quote
            [0] = "Debug Admin", --Only debug commands
            [1] = "Moderator", --Some commands, can't kick, no "fun" commands
            [2] = "Admin", --Most commands, can't ban or shutdown
            [3] = "Super Admin",--All commands, can be kicked by full admin
            [4] = "Owner Admin", --All commands, except :admin
            [5] = "Creator Admin", --All commands, including :admin
        },
        GroupAdminLevels = ConfigurationTable.GroupAdminLevels or {},
        BannedUsers = ConfigurationTable.BannedUsers or {},
        CommandLevelOverrides = ConfigurationTable.CommandLevelOverrides or {},
        FeatureFlagOverrides = ConfigurationTable.FeatureFlagOverrides or {},
        CommandConfigurations = ConfigurationTable.CommandConfigurations or DEFAULT_COMMAND_CONFIGURATIONS,
    }, Configuration) :: Configuration

    --Confirm all DEFAULT_COMMAND_CONFIGURATIONS exist within CommandConfigurations.
    for Name, Value in DEFAULT_COMMAND_CONFIGURATIONS do
        if self.CommandConfigurations[Name] ~= nil then continue end
        self.CommandConfigurations[Name] = Value
    end
    
    --DEFAULT_COMMAND_CONFIGURATIONS that default to other specified configurations.
    if not self.CommandConfigurations.PersistentBanImmuneLevel then
        self.CommandConfigurations.PersistentBanImmuneLevel = self.PersistentCommandsLevel
    end

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
    return self
end

--[[
Raw configuration used table. This is intended for custom
configuration entries used for custom deployments.
--]]
function Configuration.GetRaw(self: Configuration): {[string]: any}
    return self.RawConfiguration
end

--[[
Returns the admin level to use for an integrated command.
--]]
function Configuration.GetCommandAdminLevel(self: Configuration, Category: string, Command: string): number
    --Get the category default.
    local CategoryDefault = self[`{Category}Level`] :: number
    if not CategoryDefault then
        error(`{Category}" is not a category supported by the configuration.`)
    end

    --Return the override or the default.
    if self.CommandLevelOverrides[Category] and self.CommandLevelOverrides[Category][Command] then
        return self.CommandLevelOverrides[Category][Command]
    else
        return CategoryDefault
    end
end



return Configuration