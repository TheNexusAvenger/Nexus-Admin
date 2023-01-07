--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unchar",
    Category = "FunCommands",
    Description = "Resets the character appearance of a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to reset the character.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            task.spawn(function()
                --Get the original position.
                local HumanoidRootPart = (Player.Character :: Model):FindFirstChild("HumanoidRootPart") :: BasePart
                if not HumanoidRootPart then return end
                local HumanoidCFrame = HumanoidRootPart.CFrame

                --Set the character appearance.
                Player.CharacterAppearanceId = Player.UserId

                --Respawn the character.
                Player:LoadCharacter()
                local Character = Player.Character
                while not Character do
                    task.wait()
                    Character = Player.Character
                end
                ((Character :: Model):WaitForChild("HumanoidRootPart") :: BasePart).CFrame = HumanoidCFrame
            end)
        end
    end,
}