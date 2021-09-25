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
    self:InitializeSuper("unsparkles","FunCommands","Removes all sparkles from a set of players.")
    
    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to remove sparkles from.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Remove the sparkles.
    for _,Player in pairs(Players) do
        if Player.Character then
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                for _,Sparkles in pairs(HumanoidRootPart:GetChildren()) do
                    if Sparkles.Name == "NexusAdminSparkles" then
                        Sparkles:Destroy()
                    end
                end
            end
        end
    end
end



return Command