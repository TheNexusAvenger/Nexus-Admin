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
    self:InitializeSuper("thru","UsefulFunCommands","Teleports a set of players forward a given amount of studs.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Player",
            Description = "Players to move.",
        },
        {
            Type = "number",
            Name = "Distance",
            Description = "Distance to move forward.",
            Optional = true,
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players,Distance)
    self.super:Run(CommandContext)
    Distance = Distance or 0

    --Telelport the players.
    for _,Player in pairs(Players) do
        local Character = Player.Character
        if Player.Character then
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0,0,-Distance)
            end
        end
    end
end



return Command