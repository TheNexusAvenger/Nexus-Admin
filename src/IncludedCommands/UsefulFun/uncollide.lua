--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local PhysicsService = game:GetService("PhysicsService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "uncollide",
    Category = "UsefulFunCommands",
    Description = "Makes a set of players unable to collide with each other.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to make uncollidable with each other.",
        },
    },
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        Api.CommandData.PlayerCollisionEvents = {}

        --Determine if the collision group exists.
        local PlayerCollisionGroupExists = false
        for _, GroupData in PhysicsService:GetRegisteredCollisionGroups() do
            if GroupData.name == "NexusAdmin_PlayerCollisionGroup" then
                PlayerCollisionGroupExists = true
                break
            end
        end

        --Create the collision group.
        if not PlayerCollisionGroupExists then
            PhysicsService:RegisterCollisionGroup("NexusAdmin_PlayerCollisionGroup")
            PhysicsService:CollisionGroupSetCollidable("NexusAdmin_PlayerCollisionGroup", "NexusAdmin_PlayerCollisionGroup", false)
        end
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Make the players collidable.
        for _, Player in Players do
            --Disconnect the events.
            if Api.CommandData.PlayerCollisionEvents[Player] then
                for _, Event in Api.CommandData.PlayerCollisionEvents[Player] do
                    Event:Disconnect()
                end
                Api.CommandData.PlayerCollisionEvents[Player] = {}
            end

            --[[
            Makes the current character uncollidable.
            --]]
            local function MakeCharacterUncollidable()
                if Player.Character then
                    --Set the collision group of the existing parts.
                    for _, Part in Player.Character:GetDescendants() do
                        if Part:IsA("BasePart") then
                            Part.CollisionGroup = "NexusAdmin_PlayerCollisionGroup"
                        end
                    end
                    
                    --Connect the new parts being added.
                    table.insert(Api.CommandData.PlayerCollisionEvents[Player], Player.Character.DescendantAdded:Connect(function(Part)
                        if Part:IsA("BasePart") then
                            Part.CollisionGroup = "NexusAdmin_PlayerCollisionGroup"
                        end
                    end))
                end
            end

            --Make the character uncollidable.
            Api.CommandData.PlayerCollisionEvents[Player] = {
                Player.CharacterAdded:Connect(MakeCharacterUncollidable),
            }
            MakeCharacterUncollidable()
        end
    end,
}