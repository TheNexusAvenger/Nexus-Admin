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
    self:InitializeSuper("chatlogs","BasicCommands","Opens up a window containing the chat logs.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)

    --Display the text window.
    local Window = ScrollingTextWindow.new()
    Window.Title = "Chat Logs"
    Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
        --Get the logs.
        if not self.Logs or ForceRefresh then
            self.Logs = self.API.EventContainer:WaitForChild("GetChatLogs"):InvokeServer()
        end

        --Filter and return the logs.
        local FilteredLogs = {}
        for _,Message in pairs(self.Logs) do
            if string.find(string.lower(Message),string.lower(SearchTerm)) then
                table.insert(FilteredLogs,Message)
            end
        end
        return FilteredLogs
    end
    Window:Show()
end



return Command