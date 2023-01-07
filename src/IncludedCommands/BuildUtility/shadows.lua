--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Lighting = game:GetService("Lighting")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "shadows",
    Category = "BuildUtility",
    Description = "Toggles the shadows",
    ServerRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        if Api.CommandData.LightingProperties and not Api.CommandData.LightingProperties.GlobalShadows then
            Api.CommandData.LightingProperties.GlobalShadows = Lighting.GlobalShadows
        end
        Lighting.GlobalShadows = not Lighting.GlobalShadows
    end,
}