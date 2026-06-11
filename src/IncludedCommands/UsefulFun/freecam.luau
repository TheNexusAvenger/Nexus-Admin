--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "freecam",
    Category = "UsefulFunCommands",
    Description = "Enables free camera for the calling player. Use Shift + P to toggle.",
    ClientRun = function(CommandContext: Types.CmdrCommandContext)
        --Return if it is already enabled.
        local PlayerGui = CommandContext.Executor:WaitForChild("PlayerGui")
        if PlayerGui:FindFirstChild("Freecam") then
            return "Freecam already enabled."
        end

        --Load Freecam.
        local FreecamGui = Instance.new("ScreenGui")
        FreecamGui.Name = "Freecam"
        FreecamGui.ResetOnSpawn = false
        FreecamGui.Parent = PlayerGui

        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local _ = require(Util.ClientResources:WaitForChild("FreeCamera")) :: any
        return "Freecam enabled."
    end,
}
