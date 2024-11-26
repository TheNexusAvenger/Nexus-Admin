--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"usage", "about"},
    Category = "Administrative",
    Description = "Displays the usage information of Nexus Admin.",
    Prefix = "!",
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()
        
        --Display the text window.
        local Window = Api.Window:CreateWindow("About")
        Window:AddTextList():SetLines({
            "Welcome to Nexus Admin (by TheNexusAvenger).",
            "Built on Cmdr (by evaera)",
            Api.Configuration.Version,
            "",
            "View commands using !cmds or :cmds.",
            `Use {(Api.Configuration.ActivationKeys[1] or Enum.KeyCode.F2).Name} to open the Cmdr command line.`,
            "Prefixes are only needed for the chat.",
            "",
            "Cmdr information: https://eryn.io/Cmdr/",
            "Nexus Admin information: https://github.com/thenexusavenger/nexus-admin",
        })
        Window:EnableResizing()
        Window:EnableClosing()
        Window:Show()
    end,
}