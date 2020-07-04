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
    self:InitializeSuper("uncollide","UsefulFunCommands","Makes a set of players unable to collide with each other.")

    self.Arguments = {
		{
			Type = "nexusAdminPlayers",
			Name = "Players",
			Description = "Players to make uncollidable with each other.",
		},
    }
    
    --Determine if the collision group exists.
    local PlayerCollisionGroupExists = false
    for _,GroupData in pairs(self.PhysicsService:GetCollisionGroups()) do
        if GroupData.name == "NexusAdmin_PlayerCollisionGroup" then
            PlayerCollisionGroupExists = true
            break
        end
    end

    --Create the collision group.
    if not PlayerCollisionGroupExists then
        self.PhysicsService:CreateCollisionGroup("NexusAdmin_PlayerCollisionGroup")
        self.PhysicsService:CollisionGroupSetCollidable("NexusAdmin_PlayerCollisionGroup","NexusAdmin_PlayerCollisionGroup",false)
    end
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

        --[[
        Makes the current character uncollidable.
        --]]
        local function MakeCharacterUncollidable()
            if Player.Character then
                --Set the collision group of the existing parts.
                for _,Part in pairs(Player.Character:GetDescendants()) do
                    if Part:IsA("BasePart") then
                        self.PhysicsService:SetPartCollisionGroup(Part,"NexusAdmin_PlayerCollisionGroup")
                    end
                end
                
                --Connect the new parts being added.
                table.insert(CommonState.PlayerCollisionEvents[Player],Player.Character.DescendantAdded:Connect(function(Part)
                    if Part:IsA("BasePart") then
                        self.PhysicsService:SetPartCollisionGroup(Part,"NexusAdmin_PlayerCollisionGroup")
                    end
                end))
            end
        end

        --Make the character uncollidable.
        CommonState.PlayerCollisionEvents[Player] = {
            Player.CharacterAdded:Connect(MakeCharacterUncollidable),
        }
        MakeCharacterUncollidable()
    end
end



return Command