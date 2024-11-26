--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"cmds","commands"},
    Category = "Administrative",
    Description = "Displays a list of all commands.",
    Prefix = "!",
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()
        
        --Show the window.
        local Window = Api.Window:CreateWindow("Commands")
        local TextList = Window:AddTextList()

        local function FilterCommands(SearchTerm: string, _: {{[string]: any}})
            --Get the commands.
            local Commands = {} :: {{[string]: any}}
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
                            local CommandString = `{Prefix}{CmdrCommand.Name} `
                            for _,Argument in CmdrCommand.Args do
                                if typeof(Argument) == "function" then
                                    CommandString ..= "[Conditional] "
                                else
                                    if Argument.Optional == true then
                                        CommandString ..= `({Argument.Name}) `
                                    else
                                        CommandString ..= `{Argument.Name} `
                                    end
                                end
                            end
                            if not ExistingLines[CommandString] and string.find(string.lower(CommandString), string.lower(SearchTerm)) then
                                table.insert(Commands, {Text = `{CommandString}- {CmdrCommand.Description}`})
                                ExistingLines[CommandString] = true
                            end
                        end
                    end
                end

                table.insert(Commands, {Text = ""})
            end

            --Return the commands.
            table.remove(Commands, #Commands)
            return Commands
        end

        local function UpdateText()
            TextList:SetLines(FilterCommands("", {}))
        end

        TextList:EnableSearching(FilterCommands)
        task.spawn(UpdateText)
        Window:EnableRefreshing(UpdateText)
        Window:EnableClosing()
        Window:EnableResizing()
        Window:Show()
    end,
}
