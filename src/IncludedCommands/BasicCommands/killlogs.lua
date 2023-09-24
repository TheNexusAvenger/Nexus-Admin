--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "killlogs",
    Category = "BasicCommands",
    Description = "Opens up a window containing the logs of kills.",
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        --Create the logs.
        local KillLogs = Api.Logs.new()
        Api.LogsRegistry:RegisterLogs("KillLogs", KillLogs, Api.Configuration:GetCommandAdminLevel("BasicCommands", "killlogs"))
        local CharacterAddedEvents = {}
        local DiedEvents = {}

        --[[
        Connects the a character dieing.
        --]]
        local function CharacterAdded(Player: Player, Character: Model): ()
            --Disconnect the previous event.
            if DiedEvents[Player] then
                DiedEvents[Player]:Disconnect()
            end

            --Connect the humanoid death.
            local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
            local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") :: BasePart
            DiedEvents[Player] = Humanoid.Died:Connect(function()
                --Get the information.
                local CreatorTag = Humanoid:FindFirstChild("creator")
                local KillingPlayer = CreatorTag and (CreatorTag :: ObjectValue).Value :: Player
                local KillingCharacter = KillingPlayer and KillingPlayer.Character :: Model
                local KillingCharacterTool = KillingCharacter and KillingCharacter:FindFirstChildOfClass("Tool") :: Tool
                local KillingCharacterHumanoidRootPart = KillingCharacter and KillingCharacter:FindFirstChild("HumanoidRootPart") :: BasePart

                --Build and store the message.
                local Timestamp = "["..Api.Time:GetTimeString().."]: "
                local KilledPlayerName = Player.DisplayName.." ("..Player.Name..")"
                if KillingPlayer then
                    local KillingPlayerName = KillingPlayer.DisplayName.." ("..KillingPlayer.Name..")"
                    local Message = Timestamp..KillingPlayerName.." killed "..KilledPlayerName.." "
                    if KillingCharacterTool then
                        Message = Message.."holding "..KillingCharacterTool.Name.." "
                    end
                    if KillingCharacterHumanoidRootPart then
                        Message = Message.."("..tostring((KillingCharacterHumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude).." studs)"
                    end
                    KillLogs:Add(Message)
                else
                    KillLogs:Add(Timestamp..KilledPlayerName.." died.")
                end
            end)
        end

        --[[
        Connects the characters being added for a player.
        --]]
        local function PlayerAdded(Player: Player): ()
            CharacterAddedEvents[Player] = Player.CharacterAdded:Connect(function(Character)
                CharacterAdded(Player, Character)
            end)
            if Player.Character then
                CharacterAdded(Player, Player.Character)
            end
        end

        --Connect the players.
        Players.PlayerRemoving:Connect(function(Player)
            if CharacterAddedEvents[Player] then
                CharacterAddedEvents[Player]:Disconnect()
                CharacterAddedEvents[Player] = nil
            end
            if DiedEvents[Player] then
                DiedEvents[Player]:Disconnect()
                DiedEvents[Player] = nil
            end
        end)
        Players.PlayerAdded:Connect(PlayerAdded)
        for _,Player in Players:GetPlayers() do
            task.spawn(function()
                PlayerAdded(Player)
            end)
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        local Window = ScrollingTextWindow.new()
        Window.Title = "Kill Logs"
        Window:DisplayLogs(Api.LogsRegistry:GetLogs("KillLogs"))
        Window:Show()
    end,
}