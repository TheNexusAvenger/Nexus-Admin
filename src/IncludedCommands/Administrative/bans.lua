--[[
TheNexusAvenger

Implementation of a command.
--]]

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
                    table.insert(BannedNames, BannedPlayerData[3].." ("..tostring(BannedId)..")")
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
        local Api = Util:GetApi()
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local Bans = nil
        local Window = ScrollingTextWindow.new()
        Window.Title = "Bans"
        Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
            --Get the bans.
            if not Bans or ForceRefresh then
                Bans = Api.EventContainer:WaitForChild("GetBans"):InvokeServer()
            end

            --Filter and return the bans.
            local FilteredBans = {}
            for _, Message in Bans do
                if string.find(string.lower(Message), string.lower(SearchTerm)) then
                    table.insert(FilteredBans, Message)
                end
            end
            return FilteredBans
        end
        Window:Show()
    end,
}