--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "s",
    Category = "BuildUtility",
    Description = "Executes a string as a script. ServerScriptService.LoadStringEnabled must be enabled.",
    Arguments = {
        {
            Type = "string",
            Name = "Source",
            Description = "Source to run.",
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        Api.CommandData.LoadStringEnabled = pcall(function() (loadstring("local Works = true") :: any)() end)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Source: string): string?
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Run the source.
        if not Api.CommandData.LoadStringEnabled then
            return "LoadStringEnabled is not enabled. Scripts can't be run."
        else
            (loadstring(Source) :: any)()
        end
        return nil
    end,
}