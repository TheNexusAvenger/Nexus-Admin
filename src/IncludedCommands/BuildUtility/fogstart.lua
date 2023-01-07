--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Lighting = game:GetService("Lighting")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "fogstart",
    Category = "BuildUtility",
    Description = "Sets the fog start.",
    Arguments = {
        {
            Type = "number",
            Name = "FogStart",
            Description = "Fog start to set.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, FogStart: number)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        if Api.CommandData.LightingProperties and not Api.CommandData.LightingProperties.FogStart then
            Api.CommandData.LightingProperties.FogStart = Lighting.FogStart
        end
        Lighting.FogStart = FogStart
    end,
}