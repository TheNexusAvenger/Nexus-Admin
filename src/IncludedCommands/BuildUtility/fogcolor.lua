--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Lighting = game:GetService("Lighting")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "fogcolor",
    Category = "BuildUtility",
    Description = "Sets the fog color.",
    Arguments = {
        {
            Type = "color3",
            Name = "FogColor",
            Description = "Fog color to set.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, FogColor: Color3)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        if Api.CommandData.LightingProperties and not Api.CommandData.LightingProperties.FogColor then
            Api.CommandData.LightingProperties.FogColor = Lighting.FogColor
        end
        Lighting.FogColor = FogColor
    end,
}