--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"inventory", "viewinventory"},
    Category = "BasicCommands",
    Description = "Displays the inventory of the given players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to show the inventory of.",
        },
    },
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local Inventories = nil
        local Window = ScrollingTextWindow.new()
        Window.Title = "Inventories"
        Window.GetTextLines = function(_, SearchTerm, ForceRefresh)
            --Get the inventories.
            if not Inventories or ForceRefresh then
                Inventories = {}
                for _,Player in Players do
                    local Inventory = `{Player.Name}:`
                    
                    --Add the backpack tools.
                    local Backpack = Player:FindFirstChildOfClass("Backpack")
                    if Backpack then
                        for _, Tool in Backpack:GetChildren() do
                            if Tool:IsA("BackpackItem") then
                                Inventory = `{Inventory}\n    {Tool.Name}`
                            end
                        end
                    end

                    --Add the character tools.
                    local Character = Player.Character
                    if Character then
                        for _, Tool in Character:GetChildren() do
                            if Tool:IsA("BackpackItem") then
                                Inventory = `{Inventory}\n    {Tool.Name}`
                            end
                        end
                    end

                    --Add the line.
                    table.insert(Inventories, Inventory)
                end

                --Sort the lines by name.
                table.sort(Inventories, function(a, b) return string.lower(a) < string.lower(b) end)
            end

            --Filter and return the inventories.
            local FilteredInventories = {}
            for _,Message in Inventories do
                if string.find(string.lower(Message), string.lower(SearchTerm)) then
                    table.insert(FilteredInventories, Message)
                end
            end
            return FilteredInventories
        end
        Window:Show()
    end,
}