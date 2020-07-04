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
    self:InitializeSuper("tools","BasicCommands","Opens up a window containing the list of tools usable by :give.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)

    --Display the text window.
    local Window = ScrollingTextWindow.new()
    Window.Title = "Tools"
    Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
        --Get the tools.
        if not self.Tools or ForceRefresh then
            self.Tools = self.API.EventContainer:WaitForChild("GetToolsInContainers"):InvokeServer()
        end

        --Filter and return the tools.
        local FilteredTools = {}
        for _,Message in pairs(self.Tools) do
            if Message == "" or type(Message) ~= "string" or string.find(string.lower(Message),string.lower(SearchTerm)) then
                table.insert(FilteredTools,Message)
            end
        end
        return FilteredTools
    end
    Window:Show()
end



return Command