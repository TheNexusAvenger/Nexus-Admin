--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("smoke","FunCommands","Adds a smoke to a set of players.")
    
    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to give smoke to.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Add the smoke.
    for _,Player in pairs(Players) do
        if Player.Character then
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                local Smoke = Instance.new("Smoke")
                Smoke.Color = Color3.new(100/255,100/255,100/255)
                Smoke.RiseVelocity = 5
                Smoke.Opacity = 0.75
                Smoke.Name = "NexusAdminSmoke"
                Smoke.Parent = HumanoidRootPart
            end
        end
    end
end



return Command