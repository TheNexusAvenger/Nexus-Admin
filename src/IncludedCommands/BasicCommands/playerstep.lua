--[[
TheNexusAvenger

Implementation of a command.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "playerstep",
    Category = "BasicCommands",
    Description = "Runs a command for a given set of players, but one at a time with a GUI to continue to the next player.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to run the command on.",
        },
        {
            Type = "string",
            Name = "Command",
            Description = "Command to run on the players. Use {player} for any place where the player should be inputted.",
        },
    },
    ClientRun = function(CommandContext: Types.CmdrCommandContext, PlayersToRun: {Player}, Command: string)
        local ResizableWindow = require(script.Parent.Parent.Parent:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("ResizableWindow")) :: any
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        --Create the window.
        local CommandsRanOn = {}
        local CurrentPlayer = 1
        local Camera = Workspace.CurrentCamera
        local CameraViewportSize = Camera.ViewportSize
        local PlayerStepScreenGui = Instance.new("ScreenGui")
        PlayerStepScreenGui.Name = "PlayerStepWindow"
        PlayerStepScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

        local Window = ResizableWindow.new()
        Window.Title = "Player Step (1/"..tostring(#PlayersToRun)..")"

        local PlayerStepText = Instance.new("TextBox")
        PlayerStepText.BackgroundTransparency = 1
        PlayerStepText.Size = UDim2.new(0.95, 0, 1, -10)
        PlayerStepText.Position = UDim2.new(0.025, 0, 0, 5)
        PlayerStepText.Font = Enum.Font.SourceSans
        PlayerStepText.TextColor3 = Color3.new(1, 1, 1)
        PlayerStepText.TextStrokeColor3 = Color3.new(0, 0, 0)
        PlayerStepText.ClipsDescendants = true
        PlayerStepText.ClearTextOnFocus = false
        PlayerStepText.TextEditable = false
        PlayerStepText.TextStrokeTransparency = 0
        PlayerStepText.TextSize = CameraViewportSize.Y * 0.5 * 0.045
        PlayerStepText.TextXAlignment = Enum.TextXAlignment.Left
        PlayerStepText.TextYAlignment = Enum.TextYAlignment.Top
        PlayerStepText.Text = "Loading..."
        PlayerStepText.Parent = Window.ContentsAdorn

        function Window:OnRefresh()
            --Build the text.
            local Player = PlayersToRun[CurrentPlayer]
            local PlayerCommand = string.gsub(Command, "{[Pp][Ll][Aa][Yy][Ee][Rr]}", Player.Name)
            local WindowText = "Player: "..Player.DisplayName.." ("..Player.Name..")\nCommand ran: "..tostring(PlayerCommand)
            if PlayerCommand == Command then
                WindowText = WindowText.."\n\tNo {player} was found in the command. The player may not have been added to the command."
            end
            if CurrentPlayer == #PlayersToRun then
                WindowText = WindowText.."\n\nNo other players to run."
            else
                local NextPlayer = PlayersToRun[CurrentPlayer + 1]
                WindowText = WindowText.."\n\nNext player: "..NextPlayer.DisplayName.." ("..NextPlayer.Name..")\nRefresh the window to continue."
            end
            Window.Title = "Player Step ("..tostring(CurrentPlayer).."/"..tostring(#PlayersToRun)..")"
            PlayerStepText.Text = WindowText

            --Prepare the next player.
            if CurrentPlayer < #PlayersToRun then
                CurrentPlayer += 1
            end

            --Run the command.
            if not CommandsRanOn[Player] then
                CommandsRanOn[Player] = true
                task.spawn(function()
                    local Message = Api.Executor:ExecuteCommandWithOrWithoutPrefix(PlayerCommand, Players.LocalPlayer, CommandContext:GetData())
                    if Message ~= "" then
                        Util:SendMessage(Message)
                    end
                end)
            end
        end

        function Window:OnClose()
            Window:TweenOut(Enum.NormalId.Bottom, function()
                Window:Destroy()
            end)
        end

        --Show the window.
        Window.WindowFrame.Parent = PlayerStepScreenGui
        Window.WindowFrame.Size = UDim2.new(0, CameraViewportSize.Y * 0.4, 0, CameraViewportSize.Y * 0.225)
        Window:MoveTo(Enum.NormalId.Bottom, 0.5, 0.5)
        Window:TweenTo(Enum.NormalId.Bottom)
        Window:OnRefresh()
    end,
}