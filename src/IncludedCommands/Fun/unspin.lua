--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "unspin",
    Category = "FunCommands",
    Description = "Unspins a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unspin.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart then
                    local BodyAngularVelocity = HumanoidRootPart:FindFirstChild("NexusAdminSpinEffect")
                    if BodyAngularVelocity then
                        BodyAngularVelocity:Destroy()
                    end
                end
            end
        end
    end,
}