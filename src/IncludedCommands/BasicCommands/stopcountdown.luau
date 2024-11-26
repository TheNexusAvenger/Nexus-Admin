--Implementation of a command.
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "stopcountdown",
    Category = "BasicCommands",
    Description = "Stops the current countdowns.",
    ClientLoad = function(Api: Types.NexusAdminApi)
        (IncludedCommandUtil:GetRemote("StopCountdown") :: RemoteEvent).OnClientEvent:Connect(function()
            --Stop and clear the countdowns.
            for _, Countdown in Api.CommandData.Countdowns do
                Countdown:Stop()
            end
            Api.CommandData.Countdowns = {}
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        IncludedCommandUtil:CreateRemote("RemoteEvent", "StopCountdown")
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext)
        local Util = IncludedCommandUtil.ForContext(CommandContext);

        --Send the countdown stop.
        (Util:GetRemote("StopCountdown") :: RemoteEvent):FireAllClients();

        --Clear the countdown values.
        (Util:GetRemote("PreviousCountdowns") :: StringValue).Value = "[]"
    end,
}