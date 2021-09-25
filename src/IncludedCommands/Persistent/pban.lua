--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()
Command.PersistentBans = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("PersistentBans")).GetStaticInstance()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("pban","PersistentCommands","Permanently bans a set of players by their user id or username (use user if if the name is a number) with an optional ban message.")
    
    self.Arguments = {
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
    }

    --Initialize the persistent bans.
    self.PersistentBans:Initialize()
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,PlayerNames,Message)
    self.super:Run(CommandContext)
    
    --Return if the persistent bans weren't initialized.
    if not self.PersistentBans:WasInitialized() then
        return "Persistent bans failed to initialize."
    end

    --Ban the names.
    local NamesAndIds = {}
    for _,Name in pairs(PlayerNames) do
        for _,Id in pairs(self.PersistentBans:ResolveUserIds(Name)) do
            self.PersistentBans:BanId(Id,Message)
        end
    end

    --Push the bans.
    local Worked,Return = pcall(function()
        self.PersistentBans:PushBans()
    end)
    if not Worked then
        warn("Pushing bans failed because "..tostring(Return))
    end
end



return Command