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
    self:InitializeSuper("disco","FunCommands","Toggles disco on and off.")

    self.DiscoActive = false
    self.OriginalAmbient = nil
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Ids)
    self.super:Run(CommandContext)
    
    --Toggle Disco on or off.
    self.DiscoActive = not self.DiscoActive
    if self.DiscoActive then
        coroutine.wrap(function()
            self.OriginalAmbient = self.Lighting.Ambient
            while self.DiscoActive do
				self.Lighting.Ambient = Color3.new(math.random(),math.random(),math.random())
				wait(0.25)
			end
        end)()
    else
        self.Lighting.Ambient = self.OriginalAmbient
    end
end



return Command