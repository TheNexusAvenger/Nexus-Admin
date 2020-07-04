--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Logs = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("Logs"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("chatlogs","BasicCommands","Opens up a window containing the chat logs.")
    self.ChatLogs = Logs.new()

    --Create the remote function.
    local GetChatLogsRemoteFunction = Instance.new("RemoteFunction")
    GetChatLogsRemoteFunction.Name = "GetChatLogs"
    GetChatLogsRemoteFunction.Parent = self.API.EventContainer

    function GetChatLogsRemoteFunction.OnServerInvoke(Player)
        if self.API.Authorization:IsPlayerAuthorized(Player,self.AdminLevel) then
            return self.ChatLogs:GetLogs()
        else
            return {"Unauthorized"}
        end
    end

    --[[
    Connects the Chatted event for a player.
    --]]
    local function ConnectPlayerChatted(Player)
        Player.Chatted:Connect(function(Message)
            self.ChatLogs:Add(Player.Name.." ["..self.API.Time:GetTimeString().."]: "..self.API.Filter:FilterString(Message,Player))
        end)
    end

    --Connect the players.
    self.Players.PlayerAdded:Connect(ConnectPlayerChatted)
    for _,Player in pairs(self.Players:GetPlayers()) do
        ConnectPlayerChatted(Player)
    end
end



return Command