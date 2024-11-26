--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "where",
    Category = "UsefulFunCommands",
    Description = "Displays the positions of the given players.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to get the locations of.",
        },
    },
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        --Show the window.
        local Window = Api.Window:CreateWindow("Positions")
        local TextList = Window:AddTextList()
        TextList:EnableSearching()

        local function UpdateText()
            local Positions = {}
            for _, Player in Players do
                local Character = Player.Character
                if Character then
                    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart
                    if HumanoidRootPart then
                        local Position = HumanoidRootPart.Position
                        table.insert(Positions, string.format(`{Player.Name}: %.3f,%.3f,%.3f`, Position.X, Position.Y, Position.Z))
                    else
                        table.insert(Positions, `{Player.Name} has no HumanoidRootPart.`)
                    end
                else
                    table.insert(Positions, `{Player.Name} has no character.`)
                end
            end
            table.sort(Positions,function(a, b) return string.lower(a) < string.lower(b) end)
            TextList:SetLines(Positions)
        end

        task.spawn(UpdateText)
        Window:EnableRefreshing(UpdateText)
        Window:EnableClosing()
        Window:EnableResizing()
        Window:Show()
    end,
}