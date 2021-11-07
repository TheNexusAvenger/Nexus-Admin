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
    self:InitializeSuper("fly","UsefulFunCommands","Gives a set of players the ability to fly. Use E to toggle on/off.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to fly.",
        },
    }
    
    --Create the remote event.
    local FlyPlayerEvent = Instance.new("RemoteEvent")
    FlyPlayerEvent.Name = "FlyPlayer"
    FlyPlayerEvent.Parent = self.API.EventContainer
    self.FlyPlayerEvent = FlyPlayerEvent

    --Update the collision groups.
    self.API.FeatureFlags:AddFeatureFlag("AllowFlyingThroughMap",true)
    coroutine.wrap(function()
        while true do
            --Determine if the flying collision group exists.
            local HasFlyCollisionGroup = false
            for _,CollisionGroup in pairs(self.PhysicsService:GetCollisionGroups()) do
                if CollisionGroup.name == "NexusAdmin_FlyingPlayerCollisionGroup" then
                    HasFlyCollisionGroup = true
                    break
                end
            end

            --Set up the collision group for flying.
            local AllowFlyingThroughMap = self.API.FeatureFlags:GetFeatureFlag("AllowFlyingThroughMap")
            if AllowFlyingThroughMap and not HasFlyCollisionGroup then
                self.PhysicsService:CreateCollisionGroup("NexusAdmin_FlyingPlayerCollisionGroup")
            end

            --Update the collision groups.
            if HasFlyCollisionGroup then
                for _,CollisionGroup in pairs(self.PhysicsService:GetCollisionGroups()) do
                    self.PhysicsService:CollisionGroupSetCollidable(CollisionGroup.name,"NexusAdmin_FlyingPlayerCollisionGroup",not AllowFlyingThroughMap)
                end
            end

            --Wait to run again.
            wait(5)
        end
    end)()
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext,Players)
    self.super:Run(CommandContext)
    
    --Fling the players.
    for _,Player in pairs(Players) do
        self.FlyPlayerEvent:FireClient(Player)
    end
end



return Command