--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Lighting = game:GetService("Lighting")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "fixlighting",
    Category = "BuildUtility",
    Description = "Reverts the lighting changed by the admin.",
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        Api.CommandData.LightingProperties = {}
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Revert the settings.
        for Key,Value in Api.CommandData.LightingProperties do
            Lighting[Key] = Value
        end
        Api.CommandData.LightingProperties = {}
    end,
}