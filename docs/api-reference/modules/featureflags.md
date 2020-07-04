# FeatureFlags
Handles feature flags (toggles features being enabled or disabled).<br>
Exists on the server and client.

## `Event<string,boolean> FeatureFlags.FeatureFlagChanged`
Event for when a feature flag gets changed, including the name
and new value.

## `void FeatureFlags:AddFeatureFlag(string Name,boolean Value)`
Adds a feature flag if it wasn't set before.

## `void FeatureFlags:SetFeatureFlag(string Name,boolean Value)`
Sets a feature flag value.

## `boolean FeatureFlags:GetFeatureFlag(string Name)`
Returns the feature flag value.

## `Event<boolean> FeatureFlags:GetFeatureFlagChangedEvent(string Name)`
Returns an event for a specific feature flag changing.