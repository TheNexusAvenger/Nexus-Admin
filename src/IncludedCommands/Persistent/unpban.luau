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
        require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans")).GetInstance(Api)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, PlayerNames: {string}, ExperienceWide: boolean): string?
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()
        local PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans")).GetInstance(Api)

        --Return if the persistent bans weren't initialized.
        if not PersistentBans:WasInitialized() then
            if Api.CommandData.PersistentBans.Enabled then
                return "Persistent Bans failed to initialize."
            else
                return "Roblox Ban API is disabled within this experience."
            end
        end

        --Unban the names.
        local Ids = {}
        for _, Name in PlayerNames do
            for _, Id in PersistentBans:ResolveUserIds(Name) do
                table.insert(Ids, Id)
            end
        end

        local Success, Response = PersistentBans:UnbanIds({
            ["UserIds"] = Ids,
            ["ApplyToUniverse"] = ExperienceWide
        }, CommandContext.Executor.UserId, CommandContext.Executor.Name);

        (IncludedCommandUtil:GetRemote("PersistentBanResponse") :: RemoteEvent):FireClient(CommandContext.Executor, "Unban", Success, Response or "UserIds unbanned.", Ids, {})

        return nil
    end,
}