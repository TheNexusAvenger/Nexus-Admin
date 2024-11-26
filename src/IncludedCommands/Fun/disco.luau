--Implementation of a command.
--!strict

local Lighting = game:GetService("Lighting")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "disco",
    Category = "FunCommands",
    Description = "Toggles disco on and off.",
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()

        --Toggle Disco on or off.
        Api.CommandData.DiscoActive = not Api.CommandData.DiscoActive
        if Api.CommandData.DiscoActive then
            task.spawn(function()
                Api.CommandData.DiscoOriginalAmbient = Lighting.Ambient
                while Api.CommandData.DiscoActive do
                    Lighting.Ambient = Color3.new(math.random(), math.random(), math.random())
                    wait(0.25)
                end
            end)
        else
            Lighting.Ambient = Api.CommandData.DiscoOriginalAmbient
        end
    end,
}