# Included Feature Flags
This page includes the feature flags included for internal
implementations. Most likely developers working on a custom
integration will be the only ones changing them.

## UseNativeMessageGui (default: `true`)
If true, the native messages GUI will be displayed when
`Messages:DisplayMessage()` is used. If false, no GUI
is displayed intended for the developer to replace.

## UseNativeHintGui (default: `true`)
If true, the native hits GUI will be displayed when
`Messages:DisplayHint()` is used. If false, no GUI
is displayed intended for the developer to replace.

## DisplayAdminLevelNotifications (default: `true`)
If true, messages will be displayed when the player
changes admin levels as well as on join. If false, no
message will be displayed when the admin level is changed.

## AllowChatCommandExecuting (default: `true`)
If true, commands can be executed from the chat with
prefixes used. If false, chat executing will be ignored.

## AllowDroppingSwords (default: `false`)
If true, players will be able to drop swords. 
If false they won't.
