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
    self:InitializeSuper("view","UsefulFunCommands","Views a given player.")

    self.Arguments = {
		{
			Type = "player",
			Name = "Player",
			Description = "Players to view.",
		},
	}
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Player)
	self.super:Run(CommandContext)

    --Change the view.
    if Player.Character then
        local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        local Camera = self.Workspace.CurrentCamera
        if Humanoid then
            Camera.CameraSubject = Humanoid
            if Player == CommandContext.Executor then
                Camera.CameraType = "Custom"
            else
                Camera.CameraType = "Track"
            end
        end
    end
end



return Command