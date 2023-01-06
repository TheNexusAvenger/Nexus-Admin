--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"cmds","commands","help"},
    Category = "Administrative",
    Description = "Displays a list of all commands, or inspects one command.",
    Prefix = "!",
    Arguments = {
        {
            Type = "command";
            Name = "Command";
            Description = "The command to view information on (command line only)";
            Optional = true;
        },
    },
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Command: string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local Window = ScrollingTextWindow.new()
        Window.Title = "Commands"
        Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
            --Get the commands.
            local Commands = {} :: {string | {[string]: any}}
            local ExistingLines = {}
            local AdminLevel = Api.Authorization:GetAdminLevel(CommandContext.Executor)
            for GroupName, GroupCommands in (Api.Registry :: any).CommandsByGroup do
                table.insert(Commands, {Text = GroupName, Font = Enum.Font.SourceSansBold})
                for _,Command in GroupCommands do
                    if not Command.AdminLevel or Command.AdminLevel <= AdminLevel then
                        local CmdrCommand = (Api.Registry :: any):GetReplicatableCmdrData(Command)

                        --Determine the prefixes.
                        local Prefixes = Command.Prefix
                        if not Prefixes then
                            Prefixes = {""}
                        elseif type(Prefixes) == "string" then
                            Prefixes = {Prefixes}
                        end

                        --Add the command.
                        for _,Prefix in Prefixes do
                            local CommandString = Prefix..CmdrCommand.Name.." "
                            for _,Argument in CmdrCommand.Args do
                                if Argument.Optional == true then
                                    CommandString = CommandString.."("..Argument.Name..") "
                                else
                                    CommandString = CommandString..Argument.Name.." "
                                end
                            end
                            if not ExistingLines[CommandString] and string.find(string.lower(CommandString), string.lower(SearchTerm)) then
                                table.insert(Commands,CommandString.."- "..CmdrCommand.Description)
                                ExistingLines[CommandString] = true
                            end
                        end
                    end
                end

                table.insert(Commands, "")
            end

            --Return the commands.
            table.remove(Commands, #Commands)
            return Commands
        end
        Window:Show()
    end,
}