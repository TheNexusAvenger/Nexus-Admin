--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "where",
    Category = "UsefulFunCommands",
    Description = "Displays the positions of the given players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to get the locations of.",
        },
    },
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local Positions = nil
        local Window = ScrollingTextWindow.new()
        Window.Title = "Positions"
        Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
            --Get the positions.
            if not Positions or ForceRefresh then
                Positions = {}
                for _, Player in Players do
                    local Character = Player.Character
                    if Character then
                        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart
                        if HumanoidRootPart then
                            local Position = HumanoidRootPart.Position
                            table.insert(Positions, string.format(Player.Name..": %.3f,%.3f,%.3f", Position.X, Position.Y, Position.Z))
                        else
                            table.insert(Positions, Player.Name.." has no HumanoidRootPart.")
                        end
                    else
                        table.insert(Positions, Player.Name.." has no character.")
                    end
                end
                table.sort(Positions,function(a,b) return string.lower(a) < string.lower(b) end)
            end

            --Filter and return the positions.
            local FilteredPositionss = {}
            for _, Message in Positions do
                if string.find(string.lower(Message), string.lower(SearchTerm)) then
                    table.insert(FilteredPositionss, Message)
                end
            end
            return FilteredPositionss
        end
        Window:Show()
    end,
}