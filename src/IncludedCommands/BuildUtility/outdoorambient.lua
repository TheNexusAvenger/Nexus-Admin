--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Lighting = game:GetService("Lighting")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "outdoorambient",
    Category = "BuildUtility",
    Description = "Sets the outdoor ambient.",
    Arguments = {
        {
            Type = "color3",
            Name = "OutdoorAmbient",
            Description = "OutdoorAmbient to set.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, OutdoorAmbient: Color3)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        if Api.CommandData.LightingProperties and not Api.CommandData.LightingProperties.OutdoorAmbient then
            Api.CommandData.LightingProperties.OutdoorAmbient = Lighting.OutdoorAmbient
        end
        Lighting.OutdoorAmbient = OutdoorAmbient
    end,
}