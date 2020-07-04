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

    self.Name = "clear"
	self.Aliases = {}
	self.Description = "Clear all lines above the entry line of the Cmdr window."
	self.Group = "DefaultUtil"
	self.Args = {}
end

--[[
Runs the Cmdr command.
--]]
function Command:RunCommand()
    local player = self.Players.LocalPlayer
    local gui = player:WaitForChild("PlayerGui"):WaitForChild("Cmdr")
    local frame = gui:WaitForChild("Frame")

    if gui and frame then
        for _, child in pairs(frame:GetChildren()) do
            if child.Name == "Line" and child:IsA("TextLabel") then
                child:Destroy()
            end
        end
    end
    return ""
end



return Command