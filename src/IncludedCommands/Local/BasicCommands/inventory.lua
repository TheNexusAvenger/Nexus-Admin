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
    self:InitializeSuper({"inventory","viewinventory"},"BasicCommands","Displays the inventory of the given players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to show the inventory of.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)

    --Display the text window.
    local Window = ScrollingTextWindow.new()
    Window.Title = "Inventories"
    Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
        --Get the inventories.
        if not self.Inventories or ForceRefresh then
            self.Inventories = {}
            for _,Player in pairs(Players) do
                local Inventory = Player.Name..":"
                
                --Add the backpack tools.
                local Backpack = Player:FindFirstChildOfClass("Backpack")
                if Backpack then
                    for _,Tool in pairs(Backpack:GetChildren()) do
                        if Tool:IsA("Tool") or Tool:IsA("HopperBin") then
                            Inventory = Inventory.."\n    "..Tool.Name
                        end
                    end
                end

                --Add the character tools.
                local Character = Player.Character
                if Character then
                    for _,Tool in pairs(Character:GetChildren()) do
                        if Tool:IsA("Tool") or Tool:IsA("HopperBin") then
                            Inventory = Inventory.."\n    "..Tool.Name
                        end
                    end
                end

                --Add the line.
                table.insert(self.Inventories,Inventory)
            end

            --Sort the lines by name.
            table.sort(self.Inventories,function(a,b) return string.lower(a) < string.lower(b) end)
        end

        --Filter and return the inventories.
        local FilteredInventories = {}
        for _,Message in pairs(self.Inventories) do
            if string.find(string.lower(Message),string.lower(SearchTerm)) then
                table.insert(FilteredInventories,Message)
            end
        end
        return FilteredInventories
    end
    Window:Show()
end


return Command