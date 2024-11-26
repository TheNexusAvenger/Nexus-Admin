--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "refresh",
    Category = "BasicCommands",
    Description = "Respawns a player and moves them back to where they originally were.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to refresh.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        --Refresh the players.
        for _, Player in Players do
            task.spawn(function()
                --Get the existing position.
                if not Player.Character then return end
                local HumanoidRootPart = (Player.Character :: Model):FindFirstChild("HumanoidRootPart")
                if not HumanoidRootPart then return end
                local CurrentCFrame = (HumanoidRootPart :: BasePart).CFrame

                --Load the character and move it to the original position.
                Player:LoadCharacter()
                local Character = Player.Character
                while not Character do
                    task.wait()
                    Character = Player.Character
                end
                ((Character :: Model):WaitForChild("HumanoidRootPart") :: BasePart).CFrame = CurrentCFrame
            end)
        end
    end,
}