--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local Logs = require(script.Parent.Parent.Parent:WaitForChild("Common"):WaitForChild("Logs"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("killlogs", "BasicCommands", "Opens up a window containing the logs of kills.")
    self.KillLogs = Logs.new()
    self.API.LogsRegistry:RegisterLogs("KillLogs", self.KillLogs, self.AdminLevel)

    --[[
    Connects the a character dieing.
    --]]
    local function CharacterAdded(Player, Character)
        --Connect the humanoid death.
        local Humanoid = Character:WaitForChild("Humanoid")
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        Humanoid.Died:Connect(function()
            --Get the information.
            local CreatorTag = Humanoid:FindFirstChild("creator")
            local KillingPlayer = CreatorTag and CreatorTag.Value
            local KillingCharacter = KillingPlayer and KillingPlayer.Character
            local KillingCharacterTool = KillingCharacter and KillingCharacter:FindFirstChildOfClass("Tool")
            local KillingCharacterHumanoidRootPart = KillingCharacter and KillingCharacter:FindFirstChild("HumanoidRootPart")

            --Build and store the message.
            local Timestamp = "["..self.API.Time:GetTimeString().."]: "
            local KilledPlayerName = Player.DisplayName.." ("..Player.Name..")"
            if KillingPlayer then
                local KillingPlayerName = KillingPlayer.DisplayName.." ("..KillingPlayer.Name..")"
                local Message = Timestamp..KillingPlayerName.." killed "..KilledPlayerName.." "
                if KillingCharacterTool then
                    Message = Message.."holding "..KillingCharacterTool.Name.." "
                end
                Message = Message.."("..tostring((KillingCharacterHumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude).." studs)"
                self.KillLogs:Add(Message)
            else
                self.KillLogs:Add(Timestamp..KilledPlayerName.." died.")
            end
        end)
    end

    --[[
    Connects the characters being added for a player.
    --]]
    local function PlayerAdded(Player)
        Player.CharacterAdded:Connect(function(Character)
            CharacterAdded(Player, Character)
        end)
        if Player.Character then
            CharacterAdded(Player, Player.Character)
        end
    end

    --Connect the players.
    self.Players.PlayerAdded:Connect(PlayerAdded)
    for _,Player in pairs(self.Players:GetPlayers()) do
        task.spawn(function()
            PlayerAdded(Player)
        end)
    end
end



return Command