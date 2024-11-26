--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "alias",
    Category = "Administrative",
    Description = "Creates a new, single command out of a command and given arguments. (Reimplmented for Nexus Admin)",
    Arguments = {
        {
            Type = "string";
            Name = "Name";
            Description = "The key or input type you'd like to bind the command to."
        },
        {
            Type = "string";
            Name = "Command";
            Description = "The command text you want to run. Separate multiple commands with \"&&\". Accept arguments with $1, $2, $3, etc."
        },
    },
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Name: string, Command: string): string
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Register the command in Nexus Admin for chat executing.
        Api.Registry:LoadCommand({
            Keyword = Name,
            Group = "Aliases",
            Prefix = Api.Configuration.CommandPrefix,
        } :: any);

        --Register the Cmdr alias.
        (CommandContext.Cmdr.Registry :: any):RegisterCommandObject((CommandContext.Cmdr.Util :: any).MakeAliasCommand(Name,Command), true)
        return `Created alias {Name}`
    end
}