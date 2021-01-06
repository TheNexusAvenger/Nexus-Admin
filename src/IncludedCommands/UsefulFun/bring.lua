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
    self:InitializeSuper("bring","UsefulFunCommands","Teleports a set of players to you.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to teleport.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
	self.super:Run(CommandContext)
    
    --Get the target location.
    local TargetLocation
    if CommandContext.Executor.Character then
        local HumanoidRootPart = CommandContext.Executor.Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            TargetLocation = HumanoidRootPart.CFrame
        end
    end

    --Telelport the players.
    local Radius = math.max(10,#Players)
    if TargetLocation then
        for _,Player in pairs(Players) do
            if Player ~= CommandContext.Executor then
                self:TeleportPlayer(Player,TargetLocation * CFrame.new(math.random(-Radius,Radius)/10,0,math.random(-Radius,Radius)/10))
            end
        end
    end
end



return Command