--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local ResizableWindow = require(script.Parent.Parent.Parent:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("ResizableWindow"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("playerstep", "BasicCommands", "Runs a command for a given set of players, but one at a time with a GUI to continue to the next player.")

    self.Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to run the command one.",
        },
        {
            Type = "string",
            Name = "Command",
            Description = "Command to run on the players. Use {player} for any place where the player should be inputted.",
        },
    }
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext, Players, Command)
    self.super:Run(CommandContext)

    --Create the window.
    local CommandsRanOn = {}
    local CommandObject = self
    local CurrentPlayer = 1
    local Camera = self.Workspace.CurrentCamera
    local CameraViewportSize = Camera.ViewportSize
    local PlayerStepScreenGui = Instance.new("ScreenGui")
    PlayerStepScreenGui.Name = "PlayerStepWindow"
    PlayerStepScreenGui.Parent = self.Players.LocalPlayer:WaitForChild("PlayerGui")

    local Window = ResizableWindow.new()
    Window.Title = "Player Step (1/"..tostring(#Players)..")"

    local PlayerStepText = Instance.new("TextLabel")
    PlayerStepText.BackgroundTransparency = 1
    PlayerStepText.Size = UDim2.new(0.95, 0, 1, -10)
    PlayerStepText.Position = UDim2.new(0.025, 0, 0, 5)
    PlayerStepText.Font = Enum.Font.SourceSans
    PlayerStepText.TextColor3 = Color3.new(1, 1, 1)
    PlayerStepText.TextStrokeColor3 = Color3.new(0, 0, 0)
    PlayerStepText.ClipsDescendants = true
    PlayerStepText.TextStrokeTransparency = 0
    PlayerStepText.TextSize = CameraViewportSize.Y * 0.5 * 0.045
    PlayerStepText.TextXAlignment = Enum.TextXAlignment.Left
    PlayerStepText.TextYAlignment = Enum.TextYAlignment.Top
    PlayerStepText.Text = "Loading..."
    PlayerStepText.Parent = Window.ContentsAdorn

    function Window:OnRefresh()
        --Build the text.
        local Player = Players[CurrentPlayer]
        local PlayerCommand = string.gsub(Command, "{[Pp][Ll][Aa][Yy][Ee][Rr]}", Player.Name)
        local WindowText = "Player: "..Player.DisplayName.." ("..Player.Name..")\nCommand ran: "..tostring(PlayerCommand)
        if PlayerCommand == Command then
            WindowText = WindowText.."\n\tNo {player} was found in the command. The player may not have been added to the command."
        end
        if CurrentPlayer == #Players then
            WindowText = WindowText.."\n\nNo other players to run."
        else
            local NextPlayer = Players[CurrentPlayer + 1]
            WindowText = WindowText.."\n\nNext player: "..NextPlayer.DisplayName.." ("..NextPlayer.Name..")\nRefresh the window to continue."
        end
        Window.Title = "Player Step ("..tostring(CurrentPlayer).."/"..tostring(#Players)..")"
        PlayerStepText.Text = WindowText

        --Prepare the next player.
        if CurrentPlayer <= #Players then
            CurrentPlayer += 1
        end

        --Run the command.
        if not CommandsRanOn[Player] then
            CommandsRanOn[Player] = true
            local Message = CommandObject.API.Executor:ExecuteCommandWithOrWithoutPrefix(PlayerCommand, CommandObject.Players.LocalPlayer, CommandContext:GetData())
            if Message ~= "" then
                CommandObject:SendMessage(Message)
            end
        end
    end

    function Window:OnClose()
        Window.WindowFrame:TweenPosition(UDim2.new(0, Window.WindowFrame.AbsolutePosition.X, 0, Camera.ViewportSize.Y), "Out", "Back", 0.5, false, function()
            Window:Destroy()
        end)
    end

    --Show the window.
    Window.WindowFrame.Parent = PlayerStepScreenGui
    Window.WindowFrame.Size = UDim2.new(0, CameraViewportSize.Y * 0.4, 0, CameraViewportSize.Y * 0.225)
    Window.WindowFrame.Position = UDim2.new(0, (CameraViewportSize.X / 2) - (Window.WindowFrame.AbsoluteSize.X / 2), 0, CameraViewportSize.Y)
    Window.WindowFrame:TweenPosition(UDim2.new(0, (CameraViewportSize.X / 2) - (Window.WindowFrame.AbsoluteSize.X / 2), 0, CameraViewportSize.Y * 0.7), "Out", "Back", 0.5, false)
    Window:OnRefresh()
end



return Command