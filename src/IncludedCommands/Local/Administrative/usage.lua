--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local ScrollingTextWindow = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ScrollingTextWindow"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("usage","Administrative","Displays the usage information of Nexus Admin.")

    self.Prefix = {"!",self.API.Configuration.CommandPrefix}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)

    --Display the text window.
    local Window = ScrollingTextWindow.new(true)
    Window.Title = "About"
    Window.GetTextLines = function(_)
        return {
            "Welcome to Nexus Admin (by TheNexusAvenger).",
            "Built on Cmdr (by evaera)",
            self.API.Configuration.Version,
            "",
            "View commands using !cmds or :cmds.",
            "Use \\ to open the Cmdr command line.",
            "Prefixes are only needed for the chat.",
            "",
            "Cmdr information: https://eryn.io/Cmdr/",
            "Nexus Admin information: https://github.com/thenexusavenger/nexus-admin",
        }
    end
    Window:Show()
end



return Command