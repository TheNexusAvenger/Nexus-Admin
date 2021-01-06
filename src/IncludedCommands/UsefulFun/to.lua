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
    self:InitializeSuper("to","UsefulFunCommands","Teleports you to another player.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Player",
			Description = "Player to teleport to.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,TargetPlayers)
	self.super:Run(CommandContext)
    
    --Get the target location.
    local TargetLocation
    local TargetPlayer
    for _,NewTargetPlayer in pairs(TargetPlayers) do
        if NewTargetPlayer.Character then
            local HumanoidRootPart = NewTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                TargetPlayer = NewTargetPlayer
                TargetLocation = HumanoidRootPart.CFrame
                break
            end
        end
    end

    --Telelport the executing player.
    if TargetLocation then
        local Player = CommandContext.Executor
        if Player ~= TargetPlayer then
            self:TeleportPlayer(Player,TargetLocation * CFrame.new(math.random(-20,20)/10,0,math.random(-20,20)/10))
        end
    end
end



return Command