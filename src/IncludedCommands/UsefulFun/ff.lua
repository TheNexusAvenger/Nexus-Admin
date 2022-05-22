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
    self:InitializeSuper("ff","UsefulFunCommands","Adds a force field to the given players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give force fields.",
        },
        {
            Type = "boolean",
            Name = "Invisible",
            Optional = true,
            Description = "Whether to make the forcefield invisible. Defaults to false.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext, Players, Invisible)
    self.super:Run(CommandContext)

    --Give the forcefields.
    for _,Player in pairs(Players) do
        local Character = Player.Character
        if Character then
            local ForceField = Instance.new("ForceField")
            if Invisible == true then
                ForceField.Visible = false
            end
            ForceField.Parent = Character
        end
    end
end



return Command