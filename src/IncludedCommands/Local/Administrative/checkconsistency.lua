--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local ScrollingTextWindow = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ScrollingTextWindow"))
local GetConsistencyData = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("GetConsistencyData"))
local CompareClientServer = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("CompareClientServer"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("checkconsistency", "Administrative", "Checks the consistency of a player's client and the server.")
    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to compare the client and server for.",
        },
    }

    --Connect the remote function.
    self.API.EventContainer:WaitForChild("CheckConsistency").OnClientInvoke = function()
        return GetConsistencyData(self.Players.LocalPlayer)
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
            Window.Title = "Consistency Check - "..Player.DisplayName.." ("..Player.Name..")"
            Window.GetTextLines = function(_, SearchTerm, ForceRefresh)
                --Get the output.
                if not self.Output or ForceRefresh then
                    local Response = self.API.EventContainer:WaitForChild("CheckConsistency"):InvokeServer(Player)
                    if Response.Server then
                        if Response.Client and typeof(Response.Client) == "table" then
                            Response = CompareClientServer(Response.Client, Response.Server)
                        elseif Response.Client then
                            Response = {"Client did not return any data."}
                        else
                            Response = {"Client did not return any data."}
                        end
                    end
                    self.Output = Response
                end

                --Filter and return the output.
                local FilteredOutput = {}
                for _,Message in self.Output do
                    local Text = Message
                    if type(Message) == "table" then
                        Text = Message.Text
                    end
                    if string.find(string.lower(Text), string.lower(SearchTerm)) then
                        table.insert(FilteredOutput, Message)
                    end
                end
                return FilteredOutput
            end
            Window:Show()
        end)
    end
end



return Command