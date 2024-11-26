--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "char",
    Category = "FunCommands",
    Description = "Changes the character appearance of a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to set the character.",
        },
        {
            Type = "integer",
            Name = "AppearanceId",
            Description = "User id to use.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, AppearanceId: number)
        for _, Player in Players do
            task.spawn(function()
                --Get the original position.
                local HumanoidRootPart = (Player.Character :: Model):FindFirstChild("HumanoidRootPart") :: BasePart
                if not HumanoidRootPart then return end
                local HumanoidCFrame = HumanoidRootPart.CFrame

                --Set the character appearance.
                Player.CharacterAppearanceId = AppearanceId

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