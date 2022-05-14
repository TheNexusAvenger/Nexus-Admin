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
    self:InitializeSuper("localdebug","Administrative","Displays the output of a client.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to get the local logs of.",
        },
    }

    --Connect the remote function.
    self.API.EventContainer:WaitForChild("GetClientOutput").OnClientInvoke = function()
        local Output = {}
        for _,Line in pairs(self.LogService:GetLogHistory()) do
            local LineData = {
                Text = Line.message,
            }
            table.insert(Output,LineData)

            if Line.messageType == Enum.MessageType.MessageError then
                LineData.TextColor3 = Color3.new(1,0,0)
            elseif Line.messageType == Enum.MessageType.MessageInfo then
                LineData.TextColor3 = Color3.new(102/255,127/255,1)
            elseif Line.messageType == Enum.MessageType.MessageWarning then
                LineData.TextColor3 = Color3.new(1,153/255,102/255)
            end
        end

        return Output
    end
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext, Players)
    self.super:Run(CommandContext)

    --Display the text window.
    for _, Player in pairs(Players) do
        task.spawn(function()
            local Window = ScrollingTextWindow.new()
            Window.Title = "Client Output - "..Player.DisplayName.." ("..Player.Name..")"
            Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
                --Get the output.
                if not self.Output or ForceRefresh then
                    self.Output = self.API.EventContainer:WaitForChild("GetClientOutput"):InvokeServer(Player)
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
        end)
    end
end



return Command