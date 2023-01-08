--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Workspace = game:GetService("Workspace")

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = {"grav", "setgrav"},
    Category = "UsefulFunCommands",
    Description = "Sets the gravity of a set of players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to change the gravity for.",
        },
        {
            Type = "number",
            Name = "Multiplier",
            Description = "Multiplifer of the gravity.",
            Optional = true,
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player}, Multiplier: number?)
        for _, Player in Players do
            local Character = Player.Character
            if Character then
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart then
                    --Destroy the existing gravity effect.
                    local ExistingNexusAdminGravityEffect = HumanoidRootPart:FindFirstChild("NexusAdminGravityEffect")
                    if ExistingNexusAdminGravityEffect then
                        ExistingNexusAdminGravityEffect:Destroy()
                    end
    
                    if Multiplier and Multiplier ~= 1 then
                        --Calculate the gravity of the player.
                        local Mass = 0
                        for _,Ins in Character:GetDescendants() do
                            if Ins:IsA("BasePart") then
                                Mass = Mass + (Ins:GetMass() * Workspace.Gravity)
                            end
                        end
    
                        --Create the gravity effect.
                        local NexusAdminGravityEffect = Instance.new("BodyForce")
                        NexusAdminGravityEffect.Name = "NexusAdminGravityEffect"
                        NexusAdminGravityEffect.Force = Vector3.new(0,Mass * -(Multiplier - 1),0)
                        NexusAdminGravityEffect.Parent = HumanoidRootPart
                    end
                end
            end
        end
    end,
}