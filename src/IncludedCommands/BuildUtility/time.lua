--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Lighting = game:GetService("Lighting")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "time",
    Category = "BuildUtility",
    Description = "Sets the time of day.",
    Arguments = {
        {
            Type = "number",
            Name = "Time",
            Description = "Time of day to set.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, ClockTime: number)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        if Api.CommandData.LightingProperties and not Api.CommandData.LightingProperties.ClockTime then
            Api.CommandData.LightingProperties.ClockTime = Lighting.ClockTime
        end
        Lighting.ClockTime = ClockTime
    end,
}