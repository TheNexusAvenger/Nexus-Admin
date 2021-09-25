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
    self:InitializeSuper("unblind","FunCommands","Unblinds a set of players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to unblind.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Blind the players.
    for _,Player in pairs(Players) do
        local PlayerGui = Player:FindFirstChild("PlayerGui")
        if PlayerGui then
            if PlayerGui:FindFirstChild("NexusAdminBlind") then
                PlayerGui:FindFirstChild("NexusAdminBlind"):Destroy()
            end
        end
    end
end



return Command