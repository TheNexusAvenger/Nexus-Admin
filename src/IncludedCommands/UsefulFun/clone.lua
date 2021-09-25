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
    self:InitializeSuper("clone","UsefulFunCommands","Clones the character of the given players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to clone.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)

    --Clone the players.
    for _,Player in pairs(Players) do
        if Player.Character then
            Player.Character.Archivable = true

            local NewCharacter = Player.Character:Clone()
            NewCharacter:TranslateBy(Vector3.new(0,6,0))
            NewCharacter.Parent = self.API.AdminItemContainer
        end
    end
end



return Command