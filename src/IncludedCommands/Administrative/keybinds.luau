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
        local Api = Util:GetClientApi()

        --Show the window.
        local Window = Api.Window:CreateWindow("Bans")
        local TextList = Window:AddTextList()
        TextList:EnableSearching()

        local function UpdateText()
            local Keybinds = {}
            for Key, Commands in Api.CommandData.Keybinds do
                for _, Command in Commands do
                    table.insert(Keybinds, `{(Key :: Enum.KeyCode).Name}: {Command}`)
                end
            end
            TextList:SetLines(Keybinds)
        end

        task.spawn(UpdateText)
        Window:EnableRefreshing(UpdateText)
        Window:EnableClosing()
        Window:EnableResizing()
        Window:Show()
    end,
}