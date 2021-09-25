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
    self:InitializeSuper("fling","UsefulFunCommands","Flings a set of players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to fling.",
        },
    }

    --Connect the remote event.
    self.API.EventContainer:WaitForChild("FlingPlayer").OnClientEvent:Connect(function()
        local Character = self.Players.LocalPlayer.Character
        if Character then
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if HumanoidRootPart and Humanoid then
                Humanoid.Sit = true
                HumanoidRootPart.Velocity = Vector3.new(math.random(-200,200),500,math.random(-200,200))
            end
        end
    end)
end



return Command