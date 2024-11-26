--Implementation of a command.
--!strict

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "spin",
    Category = "FunCommands",
    Description = "Spins a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to spin.",
        },
        {
            Type = "number",
            Name = "Speed",
            Description = "Speed to spin at.",
            Optional = true,
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Speed: number)
        Speed = Speed or 1

        for _, Player in Players do
            if Player.Character then
                local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart then
                    --Remove the existing spin effect.
                    local ExistingBodyAngularVelocity = HumanoidRootPart:FindFirstChild("NexusAdminSpinEffect")
                    if ExistingBodyAngularVelocity then
                        ExistingBodyAngularVelocity:Destroy()
                    end

                    --Add the new spin effect.
                    local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
                    BodyAngularVelocity.Name = "NexusAdminSpinEffect"
                    BodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                    BodyAngularVelocity.AngularVelocity = Vector3.new(0, 8 * Speed, 0)
                    BodyAngularVelocity.Parent = HumanoidRootPart
                end
            end
        end
    end,
}