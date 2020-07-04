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
    self:InitializeSuper("tp","UsefulFunCommands","Teleports a set of players to another player.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to teleport.",
		},
		{
			Type = "nexusAdminPlayers",
			Name = "TargetPlayer",
			Description = "Player to teleport to",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,TargetPlayers)
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

    --Telelport the players.
    local Radius = math.max(10,#Players)
    if TargetLocation then
        for _,Player in pairs(Players) do
            if Player ~= TargetPlayer then
                if Player.Character then
                    local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                    if HumanoidRootPart then
                        HumanoidRootPart.CFrame = TargetLocation * CFrame.new(math.random(-Radius,Radius)/10,0,math.random(-Radius,Radius)/10)
                    end
                end
            end
        end
    end
end



return Command