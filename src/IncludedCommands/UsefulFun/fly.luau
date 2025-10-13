--Implementation of a command.
--!strict

local UserInputService = game:GetService("UserInputService")

local FlyState = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("FlyState"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "fly",
    Category = "UsefulFunCommands",
    Description = `Gives a set of players the ability to fly. Use E on keyboard or {string.sub(UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonX), 7)} on controller to toggle on/off.`,
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to fly.",
        },
        {
            Type = "number",
            Name = "SpeedMultiplier",
            Description = "Speed multiplier to apply to the fly speed.",
            Optional = true,
        },
    },
    ClientLoad = function()
        --Empty, but forces this to be set up for the Description and FlyState.
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, SpeedMultiplier: number?)
        for _, Player in Players do
            FlyState.AddToPlayer(Player, SpeedMultiplier)
        end
    end,
}
