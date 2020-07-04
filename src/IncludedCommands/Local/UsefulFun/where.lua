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
    self:InitializeSuper("where","UsefulFunCommands","Displays the positions of the given players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to get the locations of.",
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
    Window.Title = "Positions"
    Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
        --Get the positions.
        if not self.Positions or ForceRefresh then
            self.Positions = {}
            for _,Player in pairs(Players) do
                local Character = Player.Character
                if Character then
                    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                    if HumanoidRootPart then
                        local Position = HumanoidRootPart.Position
                        table.insert(self.Positions,string.format(Player.Name..": %.3f,%.3f,%.3f",Position.X,Position.Y,Position.Z))
                    end
                end
            end
            table.sort(self.Positions,function(a,b) return string.lower(a) < string.lower(b) end)
        end

        --Filter and return the positions.
        local FilteredPositionss = {}
        for _,Message in pairs(self.Positions) do
            if string.find(string.lower(Message),string.lower(SearchTerm)) then
                table.insert(FilteredPositionss,Message)
            end
        end
        return FilteredPositionss
    end
    Window:Show()
end



return Command