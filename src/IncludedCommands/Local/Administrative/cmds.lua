--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local ScrollingTextWindow = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ScrollingTextWindow"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper({"cmds","commands"},"Administrative","Displays a list of all commands.")

    self.Prefix = {"!",self.API.Configuration.CommandPrefix}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Command)
    self.super:Run(CommandContext)

    --Display the text window.
    local Window = ScrollingTextWindow.new()
    Window.Title = "Commands"
    Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
        --Get the commands.
        local Commands = {}
        local ExistingLines = {}
        local AdminLevel = self.API.Authorization:GetAdminLevel(CommandContext.Executor)
        for GroupName,GroupCommands in pairs(self.API.Registry.CommandsByGroup) do
            table.insert(Commands,{Text=GroupName,Font="SourceSansBold"})
            for _,Command in pairs(GroupCommands) do
                if not Command.AdminLevel or Command.AdminLevel <= AdminLevel then
                    local CmdrCommand = self.API.Registry:GetReplicatableCmdrData(Command)

                    --Determine the prefixes.
                    local Prefixes = Command.Prefix
                    if not Prefixes then
                        Prefixes = {""}
                    elseif type(Prefixes) == "string" then
                        Prefixes = {Prefixes}
                    end

                    --Add the command.
                    for _,Prefix in pairs(Prefixes) do
                        local CommandString = Prefix..CmdrCommand.Name.." "
                        for _,Argument in pairs(CmdrCommand.Args) do
                            if Argument.Optional == true then
                                CommandString = CommandString.."("..Argument.Name..") "
                            else
                                CommandString = CommandString..Argument.Name.." "
                            end
                        end
                        if not ExistingLines[CommandString] and string.find(string.lower(CommandString),string.lower(SearchTerm)) then
                            table.insert(Commands,CommandString.."- "..CmdrCommand.Description)
                            ExistingLines[CommandString] = true
                        end
                    end
                end
            end

            table.insert(Commands,"")
        end

        --Return the commands.
        table.remove(Commands,#Commands)
        return Commands
    end
    Window:Show()
end



return Command