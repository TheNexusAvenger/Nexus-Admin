--Implementation of a command.
--!strict

local Workspace = game:GetService("Workspace")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "resume",
    Category = "FunCommands",
    Description = "Resumes the audio.",
    ServerRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        Api.CommandData.GlobalAudioSound:Resume()
        Api.CommandData.GlobalAudioSound.Parent = Workspace
    end,
}