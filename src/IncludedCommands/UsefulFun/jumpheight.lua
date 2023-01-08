--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "jumpheight",
    Category = "UsefulFunCommands",
    Description = "Sets the jump height of the given players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to set the jump height.",
        },
        {
            Type = "number",
            Name = "JumpHeight",
            Description = "Jump height to set.",
            Optional = true,
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, JumpHeight: number?)
        for _, Player in Players do
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid") :: Humanoid
                if Humanoid then
                    Humanoid.UseJumpPower = false
                    Humanoid.JumpHeight = JumpHeight or 7.2
                end
            end
        end
    end,
}