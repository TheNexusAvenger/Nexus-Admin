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
    self:InitializeSuper("refresh","BasicCommands","Respawns a player and moves them back to where they originally were.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to refresh.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Refresh the players.
    for _,Player in pairs(Players) do
        coroutine.wrap(function()
            --Get the existing position.
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if not HumanoidRootPart then return end
            local CurrentCFrame = HumanoidRootPart.CFrame

            --Load the character and move it to the original position.
            Player:LoadCharacter()
            local Character = Player.Character
            while not Character do wait() Character = Player.Character end
            Character:WaitForChild("HumanoidRootPart").CFrame = CurrentCFrame
        end)()
    end
end



return Command