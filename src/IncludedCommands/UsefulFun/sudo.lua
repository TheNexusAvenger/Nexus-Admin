--[[
TheNexusAvenger
Implementation of a command.
--]]
--!strict

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

local Players = game:GetService("Players")

return {
    Keyword = {"sudo"},
    Category = "UsefulFunCommands",
    Description = "Force a player to run a command.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to sudo.",
        },
        {
            Type = "string",
            Name = "Command",
            Description = "Command to use.",
        },
    },
    ClientLoad = function(Api : Types.NexusAdminApiClient)
        local SudoRemote = (IncludedCommandUtil:GetRemote("SudoRemote") :: RemoteEvent)

        local Player = Players.LocalPlayer

        SudoRemote.OnClientEvent:Connect(function(Command, SudoExecutorName)
            local Executor = Players:FindFirstChild(SudoExecutorName)
            if not Executor then return end
            local LocalPlayerLevel = Api.Authorization:YieldForAdminLevel(Player)
            local ExecutorLevel = Api.Authorization:YieldForAdminLevel(Executor)

            if ExecutorLevel < LocalPlayerLevel and Executor ~= Player then return end
            Api.Executor:ExecuteCommandWithOrWithoutPrefix(Command,Player,{Sudo=SudoExecutorName})
        end)
    end,
    ServerLoad = function(Api : Types.NexusAdminApiServer)
        local SudoRemote = (IncludedCommandUtil:CreateRemote("RemoteEvent","SudoRemote") :: RemoteEvent)
    end,
    ServerRun = function(CommandContext: Types.CmdrCommandContext, Players : {Player}, Command : string)
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi() :: Types.NexusAdminApiServer

        local SudoRemote = (Util:GetRemote("SudoRemote") :: RemoteEvent)

        local ExecutorLevel = Api.Authorization:YieldForAdminLevel(CommandContext.Executor)

        local PlayersSudoed = 0

        for _, Player in pairs(Players) do
            local PlayerLevel = Api.Authorization:YieldForAdminLevel(Player)
            if ExecutorLevel >= PlayerLevel or Player == CommandContext.Executor then
                SudoRemote:FireClient(Player,Command,CommandContext.Executor.Name)
                PlayersSudoed += 1
            end
        end

        return "Sudo'ed "..tostring(PlayersSudoed).."/"..tostring(#Players).." players."
    end
}
