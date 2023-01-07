--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Lighting = game:GetService("Lighting")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "brightness",
    Category = "BuildUtility",
    Description = "Sets the brightness.",
    Arguments = {
        {
            Type = "number",
            Name = "Brightness",
            Description = "Brightness to set.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Brightness: number)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        if Api.CommandData.LightingProperties and not Api.CommandData.LightingProperties.Brightness then
            Api.CommandData.LightingProperties.Brightness = Lighting.Brightness
        end
        Lighting.Brightness = Brightness
    end,
}