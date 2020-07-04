# Configuration
Stores and parses the configuration.<br>
Exists on the server and client.

!!! note
    The configuration is replicated to clients, but changes
    are not replicated. Changing the configuration at runtime
    is not supported.

## `string Configuration.Version`
Version of Nexus Admin as a string, including the main version, sub version,
and patch version.

## `number Configuration.VersionNumberId`
Version of Nexus Admin as a number, including the main version and sub version.
This should be used for version checking for publicly-released commands
as some people may have forked Nexus Admin to use an older version.

## `string Configuration.CmdrVersion`
Version of Cmdr used. It shouldn't be used for version checking since a commit
past the version may be in use depending on the existing state of Cmdr.

## `string Configuration.CommandPrefix`
Default command prefix for running commands. By default, it is `:`, although `!` and
`;` are also used since `:` is typically the first character of emoticons.

## `number Configuration.DefaultAdminLevel`
Default admin level for players in the game. By default, it is `-1`.

## `number Configuration.AdministrativeLevel`
Default admin level required for "Administrative" commands. By default, it is `1`.

## `number Configuration.BuildUtilityLevel`
Default admin level required for "Build Utility" commands. By default, it is `1`.

## `number Configuration.BasicCommandsLevel`
Default admin level required for "Basic Commands" commands. By default, it is `1`.

## `number Configuration.UsefulFunCommandsLevel`
Default admin level required for "Useful Fun Commands" commands. By default, it is `2`.

## `number Configuration.FunCommandsLevel`
Default admin level required for "Fun Commands" commands. By default, it is `3`.

## `number Configuration.PersistentCommandsLevel`
Default admin level required for "Persistent Commands" commands. By default, it is `4`.

## `table<number,number> Configuration.Admins`
Table with the keys being the user ids to and the values being the admin level for the user.

## `table<number,string> Configuration.AdminNames`
Table with the keys being the admin level and the value being the name of the admin leve.

!!! note
    It is possible for admins levels to exist with no name.
    It is recommended to the highest admin level name that does
    not go above the given admin level.

## `table<number,table<number,number>> Configuration.GroupAdminLevels`
Table for storing the admin levels of group members. The keys refer to the group id with the
values being a table with the keys being the role id and the value being the admin level.

## `table<number,boolean | string> Configuration.BannedUsers`
Table for storing the banned users, with the keys being the user id and either a ban
message for `true` if no ban message should be shown.

## `table<string,table<string,number>> Configuration.CommandLevelOverrides`
Table for storing overrides to command levels. `Configuration:GetCommandAdminLevel(Category,Command)`
should be used for reading it.

## `table<string,boolean> Configuration.FeatureFlagOverrides`
Fast flag overrides defined by the configuration.

## `table Configuration:GetRaw()`
Raw configuration used table. This is intended for custom configuration entries
used for custom deployments.

## `number Configuration:GetCommandAdminLevel(string Category,string Command)`
Returns the admin level to use for an integrated command.