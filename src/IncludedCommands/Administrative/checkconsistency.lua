--[[
TheNexusAvenger

Implementation of a command.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local GetConsistencyDataModule = script.Parent.Parent:WaitForChild("Resources"):WaitForChild("GetConsistencyData")
local GetConsistencyData = require(GetConsistencyDataModule)
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

    --Copy the consistency data generator.
    GetConsistencyDataModule:Clone().Parent = ReplicatedStorage:WaitForChild("NexusAdminClient"):WaitForChild("IncludedCommands"):WaitForChild("Resources")

    --Create the remote function.
    local CheckConsistencyRemoteFunction = Instance.new("RemoteFunction")
    CheckConsistencyRemoteFunction.Name = "CheckConsistency"
    CheckConsistencyRemoteFunction.Parent = self.API.EventContainer

    function CheckConsistencyRemoteFunction.OnServerInvoke(Player, TargetPlayer)
        if not TargetPlayer or not TargetPlayer.Parent then
            return {"Disconnected"}
        elseif self.API.Authorization:IsPlayerAuthorized(Player,self.AdminLevel) then
            return {
                Server = GetConsistencyData(Player),
                Client = CheckConsistencyRemoteFunction:InvokeClient(Player),
            }
        else
            return {"Unauthorized"}
        end
    end
end



return Command