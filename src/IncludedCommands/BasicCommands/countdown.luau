--Implementation of a command.
--!strict

local HttpService = game:GetService("HttpService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "countdown",
    Category = "BasicCommands",
    Description = "Creates a countdown with the given seconds.",
    Arguments = {
        {
            Type = "integer",
            Name = "Time",
            Description = "Time to count down.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApiClient)
        Api.CommandData.Countdowns = {}

        --[[
        Performs a countdown.
        --]]
        local function PerformCountdown(Duration: number)
            --Create the psuedo-object.
            local Countdown = {}
            Countdown.Active = true
            function Countdown:Start()
                for i = Duration, 1, -1 do
                    if not self.Active then return end
                    Api.Messages:DisplayHint(tostring(i), 1)
                    task.wait(1)
                end
            end
            function Countdown:Stop()
                self.Active = false
            end

            --Store the countdown and start it.
            table.insert(Api.CommandData.Countdowns, Countdown)
            Countdown:Start()
        end

        --Connect the remote event.
        (IncludedCommandUtil:GetRemote("StartCountdown") :: RemoteEvent).OnClientEvent:Connect(function(Duration)
            PerformCountdown(Duration)
        end)

        task.spawn(function()
            --Wait for the previous countdowns to load.
            local PreviousCountdownsValue = IncludedCommandUtil:GetRemote("PreviousCountdowns") :: StringValue
            while PreviousCountdownsValue.Value == "" do
                wait()
            end

            --Start the existing countdowns.
            for _, CountdownEnd in HttpService:JSONDecode(PreviousCountdownsValue.Value) do
                local RemainingTime = math.floor(CountdownEnd - os.time())
                if RemainingTime > 0 then
                    PerformCountdown(RemainingTime)
                end
            end
        end)
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        IncludedCommandUtil:CreateRemote("RemoteEvent", "StartCountdown")
        IncludedCommandUtil:CreateRemote("StringValue", "PreviousCountdowns", {Value = "[]"})
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Duration: number)
        local Util = IncludedCommandUtil.ForContext(CommandContext);

        --Send the countdown.
        (Util:GetRemote("StartCountdown") :: RemoteEvent):FireAllClients(Duration)
            
        --Store the countdown.
        local PreviousCountdownsValue = Util:GetRemote("PreviousCountdowns") :: StringValue
        local PreviousCountdowns = HttpService:JSONDecode(PreviousCountdownsValue.Value)
        table.insert(PreviousCountdowns, os.time() + Duration)
        PreviousCountdownsValue.Value = HttpService:JSONEncode(PreviousCountdowns)
    end,
}