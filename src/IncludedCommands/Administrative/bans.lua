--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local CommonState = require(script.Parent.Parent:WaitForChild("CommonState"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("bans","Administrative","Opens up a window containing the list of banned users.")

    --Create the remote function.
    local GetBansRemoteFunction = Instance.new("RemoteFunction")
    GetBansRemoteFunction.Name = "GetBans"
    GetBansRemoteFunction.Parent = self.API.EventContainer

    function GetBansRemoteFunction.OnServerInvoke(Player)
        if self.API.Authorization:IsPlayerAuthorized(Player,self.AdminLevel) then
            local BannedNames = {}
            for BannedId,BannedPlayerData in pairs(CommonState.BannedUserIds) do
                table.insert(BannedNames,BannedPlayerData[3].." ("..tostring(BannedId)..")")
            end
            table.sort(BannedNames,function(a,b) return string.lower(a) < string.lower(b) end)
            return BannedNames
        else
            return {"Unauthorized"}
        end
    end
end



return Command