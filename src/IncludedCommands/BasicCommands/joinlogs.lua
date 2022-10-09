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
    self:InitializeSuper("joinlogs", "BasicCommands", "Opens up a window containing the logs of when players joined and left.")
    self.JoinLogs = Logs.new()
    self.API.LogsRegistry:RegisterLogs("JoinLogs", self.JoinLogs, self.AdminLevel)

    --Connect the players.
    self.Players.PlayerAdded:Connect(function(Player)
        self.JoinLogs:Add("["..self.API.Time:GetTimeString().."]: "..Player.DisplayName.." ("..Player.Name..", "..tostring(Player.UserId)..") joined.")
    end)
    self.Players.PlayerRemoving:Connect(function(Player)
        self.JoinLogs:Add("["..self.API.Time:GetTimeString().."]: "..Player.DisplayName.." ("..Player.Name..", "..tostring(Player.UserId)..") left.")
    end)
    for _,Player in pairs(self.Players:GetPlayers()) do
        self.JoinLogs:Add("["..self.API.Time:GetTimeString().."]: "..Player.DisplayName.." ("..Player.Name..", "..tostring(Player.UserId)..") was already in the server when Nexus Admin loaded.")
    end
end



return Command