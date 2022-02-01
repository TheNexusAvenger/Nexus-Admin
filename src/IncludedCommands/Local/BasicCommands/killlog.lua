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
    self:InitializeSuper("killlogs", "BasicCommands", "Opens up a window containing the logs of kills.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)

    --Display the text window.
    local Window = ScrollingTextWindow.new()
    Window.Title = "Kill Logs"
    Window.GetTextLines = function(_, SearchTerm, ForceRefresh)
        --Get the logs.
        if not self.Logs or ForceRefresh then
            local KillLogs = self.API.EventContainer:WaitForChild("GetKillLogs"):InvokeServer()
            local TextLogs = {}
            for _, LogEntry in pairs(KillLogs) do
                local KilledPlayerName = LogEntry.KilledPlayer.DisplayName.." ("..LogEntry.KilledPlayer.Name..")"
                if LogEntry.KillingPlayer then
                    local KillingPlayerName = LogEntry.KillingPlayer.DisplayName.." ("..LogEntry.KillingPlayer.Name..")"
                    local Message = KillingPlayerName.." killed "..KilledPlayerName.." "
                    if LogEntry.KillingPlayerEquipedToolName then
                        Message = Message.."holding "..LogEntry.KillingPlayerEquipedToolName.." "
                    end
                    Message = Message.."("..tostring(LogEntry.Distance).." studs)"
                    table.insert(TextLogs, Message)
                else
                    table.insert(TextLogs, KilledPlayerName.." died.")
                end
            end
            self.Logs = TextLogs
        end

        --Filter and return the logs.
        local FilteredLogs = {}
        for _,Message in pairs(self.Logs) do
            if string.find(string.lower(Message), string.lower(SearchTerm)) then
                table.insert(FilteredLogs, Message)
            end
        end
        return FilteredLogs
    end
    Window:Show()
end



return Command