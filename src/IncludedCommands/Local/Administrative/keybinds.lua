--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local CommonState = require(script.Parent.Parent:WaitForChild("CommonState"))
local ScrollingTextWindow = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ScrollingTextWindow"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("keybinds","Administrative","Displays the current keybinds.")

    self.Prefix = {"!",self.API.Configuration.CommandPrefix}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Key,Command)
    self.super:Run(CommandContext)

    --Display the text window.
    local Window = ScrollingTextWindow.new()
    Window.Title = "Keybinds"
    Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
        --Filter and return the keybinds.
        local Keybinds = {}
        for Key,Commands in pairs(CommonState.Keybinds) do
            for _,Command in pairs(Commands) do
                local KeyString = string.match(tostring(Key),".-%..-%.(.+)") or tostring(Key)
                local Message = KeyString..": "..Command
                if string.find(string.lower(Message),string.lower(SearchTerm)) then
                    table.insert(Keybinds,Message)
                end
            end
        end
        return Keybinds
    end
    Window:Show()
end



return Command