--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"about", "usage"},
    Category = "Administrative",
    Description = "Displays the usage information of Nexus Admin.",
    Prefix = "!",
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any
        
        --Display the text window.
        local Window = ScrollingTextWindow.new(true)
        Window.Title = "About"
        Window.GetTextLines = function(_)
            return {
                "Welcome to Nexus Admin (by TheNexusAvenger).",
                "Built on Cmdr (by evaera)",
                Api.Configuration.Version,
                "",
                "View commands using !cmds or :cmds.",
                "Use "..(Api.Configuration.ActivationKeys[1] or Enum.KeyCode.F2).Name.." to open the Cmdr command line.",
                "Prefixes are only needed for the chat.",
                "",
                "Cmdr information: https://eryn.io/Cmdr/",
                "Nexus Admin information: https://github.com/thenexusavenger/nexus-admin",
            }
        end
        Window:Show()
    end,
}