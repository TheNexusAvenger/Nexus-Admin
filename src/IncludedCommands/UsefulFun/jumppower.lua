--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "jumppower",
    Category = "UsefulFunCommands",
    Description = "Sets the jump power of the given players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to set the jump power.",
        },
        {
            Type = "number",
            Name = "JumpPower",
            Description = "Jump power to set.",
            Optional = true,
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, JumpPower: number?)
        for _, Player in Players do
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
                if Humanoid then
                    Humanoid.UseJumpPower = true
                    Humanoid.JumpPower = JumpPower or 50
                end
            end
        end
    end,
}