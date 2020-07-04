# Authorization
Handles users being authorized.<br>
Exists on the server and client.

## `Event<Player> Authorization.AdminLevelChanged`
Event that is fired when a player's admin level changes.

## `number Authorization:GetAdminLevel(Player Player)`
Returns the admin level for a player.

## `boolean Authorization:IsPlayerAuthorized(Player Player,number AdminLevel)`
Returns if the user is authorized.

## `number Authorization:YieldForAdminLevel(Player Player)`
Waits for an admin level to be defined.
Returns it when it is initialized.

## `void Authorization:SetAdminLevel(Player Player,number AdminLevel)`
Sets the admin level for a player.

!!! warning
    This should not be used on the client since will result in
    admin levels become desyncronized from the server. This may
    lead to unsable behavior.