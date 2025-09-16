--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unpban",
    Category = "PersistentCommands",
    Description = "Unbans a set of players by their user id or username (use user if the name is a number).",
    Arguments = {
        {
            Type = "strings",
            Name = "Names",
            Description = "Players to unban.",
        },
        {
            Type = "boolean",
            Name = "Experience Wide",
            Description = "Should the unban apply to all places within the experience.\nDefaults to true",
            Default = true,
            Optional = true,
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))
        Api.CommandData.PersistentBans = PersistentBans.GetInstance(Api)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, PlayerNames: {string}, ExpWide: boolean): string?
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans"))

        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        --Return if the persistent bans weren't initialized.
        local PersistentBans = Api.CommandData.PersistentBans :: PersistentBans.PersistentBans
        if not PersistentBans:WasInitialized() then
            if Api.CommandData.PersistentBans.Disabled then
                return "RobloxBanAPI is disabled within this experience."
            else
                return "Persistent bans failed to initialize."
            end
        end

        --Unban the names.
        local Ids = {}
        for _,Name in PlayerNames do
            for _, Id in PersistentBans:ResolveUserIds(Name) do
                table.insert(Ids, Id)
            end
        end

        local Success, ErrorMessage = PersistentBans:UnbanIds({
            ["UserIds"] = Ids,
            ["ApplyToUniverse"] = ExpWide
        }, CommandContext.Executor.UserId, CommandContext.Executor.Name)

        return nil
    end,
}