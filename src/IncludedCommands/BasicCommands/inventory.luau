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
        local Api = Util:GetClientApi()

        --Show the window.
        local Window = Api.Window:CreateWindow("Inventories")
        local TextList = Window:AddTextList()
        TextList:EnableSearching()

        local function UpdateText()
            --Get the inventories.
            local Inventories = {}
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
            TextList:SetLines(Inventories)
        end

        task.spawn(UpdateText)
        Window:EnableRefreshing(UpdateText)
        Window:EnableClosing()
        Window:EnableResizing()
        Window:Show()
    end,
}