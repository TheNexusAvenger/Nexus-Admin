--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Lighting = game:GetService("Lighting")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "ambient",
    Category = "BuildUtility",
    Description = "Sets the ambient.",
    Arguments = {
        {
            Type = "color3",
            Name = "Ambient",
            Description = "Ambient to set.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Ambient: Color3)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        if Api.CommandData.LightingProperties and not Api.CommandData.LightingProperties.Ambient then
            Api.CommandData.LightingProperties.Ambient = Lighting.Ambient
        end
        Lighting.Ambient = Ambient
    end,
}