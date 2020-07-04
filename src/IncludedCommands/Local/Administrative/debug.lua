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
    self:InitializeSuper("debug","Administrative","Displays the output of the server.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)

    --Display the text window.
    local Window = ScrollingTextWindow.new()
    Window.Title = "Server Output"
    Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
        --Get the output.
        if not self.Output or ForceRefresh then
            self.Output = self.API.EventContainer:WaitForChild("GetServerOutput"):InvokeServer()
        end

        --Filter and return the output.
        local FilteredOutput = {}
        for _,Message in pairs(self.Output) do
            local Text = Message
            if type(Message) == "table" then
                Text = Message.Text
            end
            if string.find(string.lower(Text),string.lower(SearchTerm)) then
                table.insert(FilteredOutput,Message)
            end
        end
        return FilteredOutput
    end
    Window:Show()
end



return Command