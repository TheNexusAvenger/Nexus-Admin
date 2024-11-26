--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "volume",
    Category = "FunCommands",
    Description = "Changes the volume of the audio.",
    Arguments = {
        {
            Type = "number",
            Name = "Volume",
            Description = "Volume to set.",
        },
    },
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Volume: number)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetServerApi()

        Api.CommandData.GlobalAudioSound.Volume = Volume
    end,
}