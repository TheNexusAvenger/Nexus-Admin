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
    self:InitializeSuper("jumppower","UsefulFunCommands","Sets the jump power of the given players.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to set the jump power.",
        },
        {
            Type = "number",
            Name = "JumpPower",
            Description = "Jump power to set.",
            Optional = true,
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,JumpPower)
    self.super:Run(CommandContext)
    JumpPower = JumpPower or 50
    
    --Set the jump power.
    for _,Player in pairs(Players) do
        local Character = Player.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.UseJumpPower = true
                Humanoid.JumpPower = JumpPower
            end
        end
    end
end



return Command