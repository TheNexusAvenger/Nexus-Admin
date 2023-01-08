--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "thru",
    Category = "UsefulFunCommands",
    Description = "Teleports a set of players forward a given amount of studs.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Player",
            Description = "Players to move.",
        },
        {
            Type = "number",
            Name = "Distance",
            Description = "Distance to move forward.",
            Optional = true,
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Distance: number?)
        for _, Player in Players do
            local Character = Player.Character :: Model
            if Player.Character then
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart
                if HumanoidRootPart then
                    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -(Distance or 0))
                end
            end
        end
    end,
}