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
    self:InitializeSuper("jumpheight","UsefulFunCommands","Sets the jump height of the given players.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to set the jump height.",
		},
		{
			Type = "number",
			Name = "JumpHeight",
            Description = "Jump height to set.",
            Optional = true,
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,JumpHeight)
    self.super:Run(CommandContext)
    JumpHeight = JumpHeight or 7.2
	
    --Set the jump power.
    for _,Player in pairs(Players) do
        local Character = Player.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.UseJumpPower = false
                Humanoid.JumpHeight = JumpHeight
            end
        end
    end
end



return Command