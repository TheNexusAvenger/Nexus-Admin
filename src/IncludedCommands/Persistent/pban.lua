--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "pban",
    Category = "PersistentCommands",
    Description = "Permanently bans a set of players by their user id or username (use user if if the name is a number) with an optional ban message.",
    Arguments = {
        {
            Type = "strings",
            Name = "Names",
            Description = "Players to ban.",
        },
        {
            Type = "string",
            Name = "Message",
            Description = "Ban message to use.",
            Optional = true,
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        Api.CommandData.PersistentBans = PersistentBans.GetInstance(Api)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, PlayerNames: {string}, Message: string?): string?
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        --Return if the persistent bans weren't initialized.
        local PersistentBans = Api.CommandData.PersistentBans :: PersistentBans.PersistentBans
        if not PersistentBans:WasInitialized() then
            return "Persistent bans failed to initialize."
        end

        --Ban the names.
        for _,Name in PlayerNames do
            for _, Id in PersistentBans:ResolveUserIds(Name) do
                PersistentBans:BanId(Id, Message and Api.Filter:FilterString(Message, CommandContext.Executor))
            end
        end
        return nil
    end,
}