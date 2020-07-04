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
    self:InitializeSuper("unmute","BasicCommands","Unmutes a set of players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unmute.",
        },
    }
    
    --Connect the remote event.
    self.API.EventContainer:WaitForChild("UnmutePlayer").OnClientEvent:Connect(function()
        self.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true)
    end)
end



return Command