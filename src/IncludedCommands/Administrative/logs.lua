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
    self:InitializeSuper("logs","Administrative","Opens up a window containing the logs of the commands used.")
    self.API.LogsRegistry:RegisterLogs("MainLogs", self.API.Logs, self.AdminLevel)
end



return Command