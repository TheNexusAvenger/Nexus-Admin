--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "stop",
    Category = "FunCommands",
    Description = "Stops the audio.",
    ServerRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        Api.CommandData.GlobalAudioSound:Stop()
        Api.CommandData.GlobalAudioSound.Parent = nil
    end,
}