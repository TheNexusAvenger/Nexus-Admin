--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local PrivateChatWindow = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PrivateChatWindow"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper({"pchat","pc"},"BasicCommands","Starts a private chat between a set of players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to run the vote for.",
        },
        {
            Type = "string",
            Name = "Question",
            Description = "Message to send.",
        },
    }

    --Connect the remote objects.
    self.API.EventContainer:WaitForChild("SendPrivateMessage").OnClientEvent:Connect(function(Player,Message)
        local PrivateChatWindow = PrivateChatWindow.new(Player,Message)
        function PrivateChatWindow.OnMessage(_,Message)
            self.API.EventContainer:WaitForChild("SendPrivateMessage"):FireServer(Player,Message)
            PrivateChatWindow:OnClose()
        end
        PrivateChatWindow.CloseButton.MouseButton1Down:Connect(function()
            self.API.EventContainer:WaitForChild("ClosePrivateMessage"):FireServer(Player)
        end)
        PrivateChatWindow:Show()
    end)
end



return Command