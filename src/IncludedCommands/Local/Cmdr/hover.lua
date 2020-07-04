--[[
TheNexusAvenger

Implementation of a Cmdr command.
--]]

local CmdrCommand = require(script.Parent.Parent:WaitForChild("CmdrCommand"))
local Command = CmdrCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper()

    self.Name = "hover"
	self.Description = "Returns the name of the player you are hovering over."
	self.Group = "DefaultUtil"
	self.Args = {}
end

--[[
Runs the Cmdr command.
--]]
function Command:RunCommand()
    local mouse = self.Players.LocalPlayer:GetMouse()
    local target = mouse.Target

    if not target then
        return ""
    end

    local p = self.Players:GetPlayerFromCharacter(target:FindFirstAncestorOfClass("Model"))

    return p and p.Name or ""
end



return Command