--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Lighting = game:GetService("Lighting")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "fogend",
    Category = "BuildUtility",
    Description = "Sets the fog end.",
    Arguments = {
        {
            Type = "number",
            Name = "FogEnd",
            Description = "Fog start to set.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, FogEnd: number)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        if Api.CommandData.LightingProperties and not Api.CommandData.LightingProperties.FogEnd then
            Api.CommandData.LightingProperties.FogEnd = Lighting.FogEnd
        end
        Lighting.FogEnd = FogEnd
    end,
}