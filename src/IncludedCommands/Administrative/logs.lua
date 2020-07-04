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
    self:InitializeSuper("logs","Administrative","Opens up a window containing the logs of the commands used.")

    --Create the remote function.
    local GetLogsRemoteFunction = Instance.new("RemoteFunction")
    GetLogsRemoteFunction.Name = "GetLogs"
    GetLogsRemoteFunction.Parent = self.API.EventContainer

    function GetLogsRemoteFunction.OnServerInvoke(Player)
        if self.API.Authorization:IsPlayerAuthorized(Player,self.AdminLevel) then
            return self.API.Logs:GetLogs()
        else
            return {"Unauthorized"}
        end
    end
end



return Command