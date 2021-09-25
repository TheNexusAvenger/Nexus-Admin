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
    self:InitializeSuper("shutdown","BasicCommands","Shuts down the server.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Display the server is shutting down.
    for _,Player in pairs(self.Players:GetPlayers()) do
        self.API.Messages:DisplayMessage(Player,"Nexus Admin","Server is shutting down.")
    end
    wait(1)

    --Kick the players.
    for _,Player in pairs(self.Players:GetPlayers()) do
        Player:Kick("Server has shut down")
    end
    self.Players.PlayerAdded:Connect(function(Player)
        Player:Kick("Server has shut down")
    end)
end



return Command