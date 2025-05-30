--Implementation of a command.
--!strict

local Workspace = game:GetService("Workspace")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "view",
    Category = "UsefulFunCommands",
    Description = "Views a given player.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Player",
            Description = "Player to view.",
        },
    },
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Disconnect the existing player event.
        if Api.CommandData.ViewCharacterAddedEvent then
            Api.CommandData.ViewCharacterAddedEvent:Disconnect()
            Api.CommandData.ViewCharacterAddedEvent = nil
        end

        --Change the view.
        local Player = Players[1]
        if Player then
            if Player.Character then
                local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                local Camera = Workspace.CurrentCamera
                if Humanoid then
                    Camera.CameraSubject = Humanoid
                    if Player == CommandContext.Executor then
                        Camera.CameraType = Enum.CameraType.Custom
                    else
                        --Set the camera.
                        Camera.CameraType = Enum.CameraType.Track
                        local ViewCharacterAddedEvent = Player.CharacterAdded:Connect(function(Character)
                            Camera.CameraSubject = Character:WaitForChild("Humanoid")
                        end)
                        Api.CommandData.ViewCharacterAddedEvent = ViewCharacterAddedEvent

                        --Request streaming around the user.
                        if Workspace.StreamingEnabled then
                            task.spawn(function()
                                while Api.CommandData.ViewCharacterAddedEvent == ViewCharacterAddedEvent do
                                    (CommandContext.Executor :: Player):RequestStreamAroundAsync(Camera.CFrame.Position)
                                    task.wait(5)
                                end
                            end)
                        end
                    end
                end
            end
        end
    end,
}