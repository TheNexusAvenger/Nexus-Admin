--[[
TheNexusAvenger

Implementation of a command.
--]]

local BaseCommand = require(script.Parent.Parent:WaitForChild("BaseCommand"))
local ScrollingTextWindow = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("ScrollingTextWindow"))
local Command = BaseCommand:Extend()



--[[
Creates the command.
--]]
function Command:__new()
    self:InitializeSuper("admins","Administrative","Opens up a window containing the list of admins.")
end

--[[
Runs the command.
--]]
function Command:Run(CommandContext)
    self.super:Run(CommandContext)

    --Display the text window.
    local Window = ScrollingTextWindow.new()
    Window.Title = "Admins"
    Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
        SearchTerm = string.lower(SearchTerm)

        --Populate the data and sort by the level.
        local AdminLevelsData = {}
        for AdminLevel,LevelName in pairs(self.API.Configuration.AdminNames) do
            if AdminLevel >= 0 then
                table.insert(AdminLevelsData,{
                    Name = LevelName,
                    Level = AdminLevel,
                    Players = {},
                })
            end
        end
        table.sort(AdminLevelsData,function(a,b) return a.Level > b.Level end)

        --Determine the highest levels for all the players.
        for _,Player in pairs(self.Players:GetPlayers()) do
            if string.find(string.lower(Player.Name),SearchTerm) then
                for _,LevelData in pairs(AdminLevelsData) do
                    if self.API.Authorization:IsPlayerAuthorized(Player,LevelData.Level) then
                        table.insert(LevelData.Players,Player)
                        break
                    end
                end
            end
        end

        --Create and return the lines.
        local Lines = {}
        for _,LevelData in pairs(AdminLevelsData) do
            table.insert(Lines,{Text=LevelData.Name.." ("..tostring(LevelData.Level)..")",Font="SourceSansBold"})
            if #LevelData.Players == 0 then
                table.insert(Lines,{Text="(No one)",Font="SourceSansItalic"})
            else
                table.sort(LevelData.Players,function(a,b) return string.lower(a.Name) < string.lower(b.Name) end)
                for _,Player in pairs(LevelData.Players) do
                    table.insert(Lines,Player.Name.." ("..tostring(Player.UserId)..")")
                end
            end
            table.insert(Lines,"")
        end
        table.remove(Lines,#Lines)
        return Lines
    end
    Window:Show()
end



return Command