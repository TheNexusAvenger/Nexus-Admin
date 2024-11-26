--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "bans",
    Category = "Administrative",
    Description = "Opens up a window containing the list of banned users.",
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local GetBansRemoteFunction = Instance.new("RemoteFunction")
        GetBansRemoteFunction.Name = "GetBans"
        GetBansRemoteFunction.Parent = Api.EventContainer
    
        function GetBansRemoteFunction.OnServerInvoke(Player): {string}
            if Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("Administrative", "bans")) then
                local BannedNames = {}
                for BannedId, BannedPlayerData in Api.CommandData.BannedUserIds do
                    table.insert(BannedNames, `{BannedPlayerData[3]} ({BannedId})`)
                end
                table.sort(BannedNames, function(a, b) return string.lower(a) < string.lower(b) end)
                return BannedNames
            else
                return {"Unauthorized"}
            end
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        --Show the window.
        local Window = Api.Window:CreateWindow("Bans")
        local TextList = Window:AddTextList()
        TextList:EnableSearching()

        local function UpdateText()
            TextList:SetLines({"Loading..."})
            TextList:SetLines((Api.EventContainer:WaitForChild("GetBans") :: RemoteFunction):InvokeServer())
        end

        task.spawn(UpdateText)
        Window:EnableRefreshing(UpdateText)
        Window:EnableClosing()
        Window:EnableResizing()
        Window:Show()
    end,
}