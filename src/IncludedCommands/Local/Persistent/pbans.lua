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
    self:InitializeSuper("pbans","PersistentCommands","Displays a list of all permanent bans.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)

    --Display the text window.
    local Window = ScrollingTextWindow.new()
    Window.Title = "Persistent Bans"
    Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
        --Get the bans.
        if not self.Bans or ForceRefresh then
            self.Bans = self.API.EventContainer:WaitForChild("GetPersistentBans"):InvokeServer()
        end

        --Filter and return the bans.
        local FilteredBans = {}
        for _,Message in pairs(self.Bans) do
            if string.find(string.lower(Message),string.lower(SearchTerm)) then
                table.insert(FilteredBans,Message)
            end
        end
        return FilteredBans
    end
    Window:Show()
end



return Command