--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unpban",
    Category = "PersistentCommands",
    Description = "Unbans a set of players by their user id or username (use user if if the name is a number).",
    Arguments = {
        {
            Type = "strings",
            Name = "Names",
            Description = "Players to unban.",
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

        --Unban the names.
        for _,Name in PlayerNames do
            for _, Id in PersistentBans:ResolveUserIds(Name) do
                PersistentBans:UnbanId(Id)
            end
        end
        return nil
    end,
}