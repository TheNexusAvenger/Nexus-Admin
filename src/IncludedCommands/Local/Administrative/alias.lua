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
    self:InitializeSuper("alias","Administrative","Creates a new, single command out of a command and given arguments. (Reimplmented for Nexus Admin)")

    self.Arguments = {
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
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Name,Command)
    self.super:Run(CommandContext)

    --Register the command in Nexus Admin for chat executing.
    self.API.Registry:LoadCommand({
        Keyword = Name,
        Group = "Aliases",
        Prefix = self.API.Configuration.CommandPrefix,
    })

    --Register the Cmdr alias.
    CommandContext.Cmdr.Registry:RegisterCommandObject(
        CommandContext.Cmdr.Util.MakeAliasCommand(Name,Command),
        true
    )
    return "Created alias "..tostring(Name)
end



return Command