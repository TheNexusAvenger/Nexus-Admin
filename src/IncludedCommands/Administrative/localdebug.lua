--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
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

    --Create the remote function.
    local GetClientOutputRemoteFunction = Instance.new("RemoteFunction")
    GetClientOutputRemoteFunction.Name = "GetClientOutput"
    GetClientOutputRemoteFunction.Parent = self.API.EventContainer

    function GetClientOutputRemoteFunction.OnServerInvoke(Player, TargetPlayer)
        if not TargetPlayer or not TargetPlayer.Parent then
            return {"Disconnected"}
        elseif self.API.Authorization:IsPlayerAuthorized(Player,self.AdminLevel) then
            return GetClientOutputRemoteFunction:InvokeClient(TargetPlayer)
        else
            return {"Unauthorized"}
        end
    end
end



return Command