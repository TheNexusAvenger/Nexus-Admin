--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Serialization = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusAdminClient"):WaitForChild("IncludedCommands"):WaitForChild("Resources"):WaitForChild("Serialization"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("snapshot","Administrative","Displays the current ScreenGuis of a player. CoreGuis are not shown due to security permissions.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Player",
            Description = "Player to view the snapshot of. Multiple players is not supported.",
        },
    }

    --Create the remote function.
    local GetClientViewRemoteFunction = Instance.new("RemoteFunction")
    GetClientViewRemoteFunction.Name = "GetClientViewRemoteFunction"
    GetClientViewRemoteFunction.Parent = self.API.EventContainer

    function GetClientViewRemoteFunction.OnServerInvoke(Player, TargetPlayer)
        Serialization:UpdateApiReference()
        if not TargetPlayer or not TargetPlayer.Parent then
            return nil
        elseif self.API.Authorization:IsPlayerAuthorized(Player,self.AdminLevel) then
            return GetClientViewRemoteFunction:InvokeClient(TargetPlayer)
        else
            return "Unauthorized"
        end
    end
end



return Command