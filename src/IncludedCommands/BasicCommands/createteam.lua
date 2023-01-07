--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Teams = game:GetService("Teams")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "createteam",
    Category = "BasicCommands",
    Description = "Creates teams of given colors and given name.",
    Arguments = {
        {
            Type = "brickColors",
            Name = "Colors",
            Description = "Colors to create.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Colors: {BrickColor})
        local Util = IncludedCommandUtil.ForContext(CommandContext)

        --Create the teams.
        for _, Color in Colors do
            --Get if the team exists.
            local ExistingTeam
            for _, Team in Teams:GetTeams() do
                if Team.TeamColor == Color then
                    ExistingTeam = Team
                end
            end

            --Create a team or display an error.
            if ExistingTeam then
                Util:SendError("Team with color "..tostring(Color).." ("..ExistingTeam.Name..") already exists.")
            else
                local NewTeam = Instance.new("Team")
                NewTeam.TeamColor = Color
                NewTeam.AutoAssignable = false
                NewTeam.Name = tostring(Color).." Team"
                NewTeam.Parent = Teams
            end
        end
    end,
}
