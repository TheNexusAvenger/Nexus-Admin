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
    self:InitializeSuper("light","FunCommands","Adds a light to a set of players.")
    
    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to give light to.",
		},
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Add the light.
    for _,Player in pairs(Players) do
        if Player.Character then
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                local Light = Instance.new("PointLight")
                Light.Name = "NexusAdminLight"
                Light.Parent = HumanoidRootPart
            end
        end
    end
end



return Command