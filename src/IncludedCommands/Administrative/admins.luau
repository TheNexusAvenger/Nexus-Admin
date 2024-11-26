--Implementation of a command.
--!strict

local Players = game:GetService("Players")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "admins",
    Category = "Administrative",
    Description = "Opens up a window containing the list of admins.",
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetClientApi()

        --Show the window.
        local Window = Api.Window:CreateWindow("Admins")
        local TextList = Window:AddTextList()

        local function FilterAdmins(SearchTerm: string, _: {{[string]: any}})
            SearchTerm = string.lower(SearchTerm)

            --Populate the data and sort by the level.
            local AdminLevelsData = {}
            for AdminLevel, LevelName in Api.Configuration.AdminNames do
                if AdminLevel >= 0 then
                    table.insert(AdminLevelsData,{
                        Name = LevelName,
                        Level = AdminLevel,
                        Players = {},
                    })
                end
            end
            table.sort(AdminLevelsData, function(a, b) return a.Level > b.Level end)

            --Determine the highest levels for all the players.
            for _, Player in Players:GetPlayers() do
                if string.find(string.lower(Player.Name), SearchTerm) then
                    for _, LevelData in AdminLevelsData do
                        if Api.Authorization:IsPlayerAuthorized(Player, LevelData.Level) then
                            table.insert(LevelData.Players, Player)
                            break
                        end
                    end
                end
            end

            --Create and return the lines.
            local Lines = {} :: {{[string]: any}}
            for _, LevelData in AdminLevelsData do
                table.insert(Lines, {Text = `{LevelData.Name} ({LevelData.Level})`, Font = Enum.Font.SourceSansBold})
                if #LevelData.Players == 0 then
                    table.insert(Lines, {Text = "(No one)", Font = Enum.Font.SourceSansItalic})
                else
                    table.sort(LevelData.Players, function(a: Player, b: Player) return string.lower(a.Name) < string.lower(b.Name) end)
                    for _, Player in LevelData.Players do
                        table.insert(Lines, {Text = `{Player.Name} ({Player.UserId})`})
                    end
                end
                table.insert(Lines, {Text = ""})
            end
            table.remove(Lines, #Lines)
            return Lines
        end

        local function UpdateText()
            TextList:SetLines(FilterAdmins("", {}))
        end

        TextList:EnableSearching(FilterAdmins)
        task.spawn(UpdateText)
        Window:EnableRefreshing(UpdateText)
        Window:EnableClosing()
        Window:EnableResizing()
        Window:Show()
    end,
}