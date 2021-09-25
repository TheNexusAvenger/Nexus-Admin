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
    self:InitializeSuper("unchar","FunCommands","Resets the character appearance of a set of players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to reset the character.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    for _,Player in pairs(Players) do
        coroutine.wrap(function()
            --Get the original position.
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if not HumanoidRootPart then return end
            local HumanoidCFrame = HumanoidRootPart.CFrame

            --Set the character appearance.
            Player.CharacterAppearanceId = Player.UserId

            --Respawn the character.
            Player:LoadCharacter()
            local Character = Player.Character
            while not Character do wait() Character = Player.Character end
            Character:WaitForChild("HumanoidRootPart").CFrame = HumanoidCFrame
        end)()
    end
end



return Command