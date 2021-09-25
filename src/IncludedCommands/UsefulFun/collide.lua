--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local CommonState = require(script.Parent.Parent:WaitForChild("CommonState"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("collide","UsefulFunCommands","Makes a set of players able to collide with each other.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to make collidable with each other.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)

    --Make the players collidable.
    for _,Player in pairs(Players) do
        --Disconnect the events.
        if CommonState.PlayerCollisionEvents[Player] then
            for _,Event in pairs(CommonState.PlayerCollisionEvents[Player]) do
                Event:Disconnect()
            end
            CommonState.PlayerCollisionEvents[Player] = {}
        end

        --Make the character collidable.
        if Player.Character then
            for _,Part in pairs(Player.Character:GetDescendants()) do
                if Part:IsA("BasePart") then
                    self.PhysicsService:SetPartCollisionGroup(Part,"Default")
                end
            end
        end
    end
end



return Command