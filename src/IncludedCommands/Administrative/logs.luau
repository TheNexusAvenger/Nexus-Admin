--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "logs",
    Category = "Administrative",
    Description = "Opens up a window containing the logs of the commands used.",
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        Api.LogsRegistry:RegisterLogs("MainLogs", Api.Logs, Api.Configuration:GetCommandAdminLevel("Administrative", "logs"))
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local Window = ScrollingTextWindow.new()
        Window.Title = "Logs"
        Window:DisplayLogs(Api.LogsRegistry:GetLogs("MainLogs"))
        Window:Show()
    end,
}