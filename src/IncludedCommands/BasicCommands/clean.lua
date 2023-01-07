--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local Workspace = game:GetService("Workspace")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "clean",
    Category = "BasicCommands",
    Description = "Clears items that admins have created.",
    ServerRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
    
        --Clear the dropped tools.
        for _, Ins in Workspace:GetChildren() do
            if Ins:IsA("Tool") then
                Ins:Destroy()
            end
        end
    
        --Clear the admin items.
        Api.AdminItemContainer:ClearAllChildren()
    end,
}