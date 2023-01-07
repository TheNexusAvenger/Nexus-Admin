--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Workspace = game:GetService("Workspace")

local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "clearterrain",
    Category = "BuildUtility",
    Description = "Clears the terrain.",
    ServerRun = function(CommandContext: Types.CmdrCommandContext)
        Workspace.Terrain:Clear()
    end,
}