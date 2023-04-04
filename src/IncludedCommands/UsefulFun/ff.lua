--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "ff",
    Category = "UsefulFunCommands",
    Description = "Adds a force field to the given players.",
    Arguments = {
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
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Invisible: boolean?)
        for _, Player in Players do
            local Character = Player.Character
            if Character then
                local ForceField = Instance.new("ForceField")
                ForceField.Name = "NexusAdminForceField"
                if Invisible == true then
                    ForceField.Visible = false
                end
                ForceField.Parent = Character
            end
        end
    end,
}