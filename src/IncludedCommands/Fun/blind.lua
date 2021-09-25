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
    self:InitializeSuper("blind","FunCommands","Blinds a set of players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to blind.",
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
            if not PlayerGui:FindFirstChild("NexusAdminBlind") then
                local NexusAdminBlind = Instance.new("ScreenGui")
                NexusAdminBlind.Name = "NexusAdminBlind"
                NexusAdminBlind.Parent = PlayerGui
                
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(3,0,3,0)
                Frame.Position = UDim2.new(-1,0,-1,0)
                Frame.BackgroundColor3 = Color3.new(0,0,0)
                Frame.BorderSizePixel = 0
                Frame.Parent = NexusAdminBlind
            end
        end
    end
end



return Command