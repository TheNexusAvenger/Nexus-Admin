--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "stoploops",
    Category = "BasicCommands",
    Description = "Stops all active loop commands.",
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Times: number, Delay: number, Command: string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Stop and unregister the loops.
        for _, Loop in Api.CommandData.Loops do
            Loop:Stop()
        end
        Api.CommandData.Loops = {}
    end,
}