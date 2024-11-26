--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "keybinds",
    Category = "Administrative",
    Description = "Displays the current keybinds.",
    Prefix = "!",
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local Window = ScrollingTextWindow.new()
        Window.Title = "Keybinds"
        Window.GetTextLines = function(_, SearchTerm, ForceRefresh)
            --Filter and return the keybinds.
            local Keybinds = {}
            for Key, Commands in Api.CommandData.Keybinds do
                for _, Command in Commands do
                    local KeyString = string.match(tostring(Key), ".-%..-%.(.+)") or tostring(Key)
                    local Message = `{KeyString}: {Command}`
                    if string.find(string.lower(Message), string.lower(SearchTerm)) then
                        table.insert(Keybinds,Message)
                    end
                end
            end
            return Keybinds
        end
        Window:Show()
    end,
}