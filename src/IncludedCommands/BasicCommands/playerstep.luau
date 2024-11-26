--Implementation of a command.
--!strict

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
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        --Create the window.
        local CommandsRanOn = {}
        local CurrentPlayer = 1

        local Window = Api.Window:CreateWindow(`Player Step (1/{#PlayersToRun})`)
        Window:EnableResizing()

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
        PlayerStepText.TextSize = Window.TextHeight
        PlayerStepText.TextXAlignment = Enum.TextXAlignment.Left
        PlayerStepText.TextYAlignment = Enum.TextYAlignment.Top
        PlayerStepText.Text = "Loading..."
        PlayerStepText.Parent = Window.ContentsAdorn

        local function Refresh()
            --Build the text.
            local Player = PlayersToRun[CurrentPlayer]
            local PlayerCommand = string.gsub(Command, "{[Pp][Ll][Aa][Yy][Ee][Rr]}", Player.Name)
            local WindowText = `Player: {Player.DisplayName} ({Player.Name})\nCommand ran: {PlayerCommand}`
            if PlayerCommand == Command then
                WindowText ..= "\n\tNo {player} was found in the command. The player may not have been added to the command."
            end
            if CurrentPlayer == #PlayersToRun then
                WindowText ..= "\n\nNo other players to run."
            else
                local NextPlayer = PlayersToRun[CurrentPlayer + 1]
                WindowText ..= `\n\nNext player: {NextPlayer.DisplayName} ({NextPlayer.Name})\nRefresh the window to continue.`
            end
            Window:SetTitle(`Player Step ({CurrentPlayer}/{#PlayersToRun})`)
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

        Window:EnableRefreshing(Refresh)
        task.spawn(Refresh)
        Window:EnableClosing()

        --Show the window.
        Window:SetRelativeSize(0.4, 0.225)
        Window:Show(UDim2.new(0.5, 0, 0.8, 0), Vector2.new(0.5, 1), Enum.NormalId.Bottom)
    end,
}