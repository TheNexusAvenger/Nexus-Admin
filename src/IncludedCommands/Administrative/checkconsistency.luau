--Implementation of a command.
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

return {
    Keyword = "checkconsistency",
    Category = "Administrative",
    Description = "Checks the consistency of a player's client and the server.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to compare the client and server for.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApi)
        --Connect the remote function.
        local GetConsistencyData = require(script.Parent.Parent:WaitForChild("Resources"):WaitForChild("GetConsistencyData"));
        (Api.EventContainer:WaitForChild("CheckConsistency") :: RemoteFunction).OnClientInvoke = function()
            return GetConsistencyData(Players.LocalPlayer)
        end
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        --Copy the consistency data generator.
        local GetConsistencyDataModule = script.Parent.Parent:WaitForChild("Resources"):WaitForChild("GetConsistencyData")
        local GetConsistencyData = require(GetConsistencyDataModule)
        GetConsistencyDataModule:Clone().Parent = ReplicatedStorage:WaitForChild("NexusAdminClient"):WaitForChild("IncludedCommands"):WaitForChild("Resources")

        --Create the remote function.
        local CheckConsistencyRemoteFunction = Instance.new("RemoteFunction")
        CheckConsistencyRemoteFunction.Name = "CheckConsistency"
        CheckConsistencyRemoteFunction.Parent = Api.EventContainer

        function CheckConsistencyRemoteFunction.OnServerInvoke(Player, TargetPlayer)
            if not TargetPlayer or not TargetPlayer.Parent then
                return {"Disconnected"}
            elseif Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("Administrative", "checkconsistency")) then
                return {
                    Server = GetConsistencyData(TargetPlayer),
                    Client = CheckConsistencyRemoteFunction:InvokeClient(TargetPlayer),
                }
            else
                return {"Unauthorized"}
            end
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any
        local CompareClientServer = require(Util.ClientResources:WaitForChild("CompareClientServer")) :: any

        --Display the text window.
        for _, Player in Players do
            task.spawn(function()
                local Output = nil
                local Window = ScrollingTextWindow.new()
                Window.Title = `Consistency Check - {Player.DisplayName} ({Player.Name})`
                Window.GetTextLines = function(_, SearchTerm, ForceRefresh)
                    --Get the output.
                    if not Output or ForceRefresh then
                        xpcall(function()
                            local Response = (Api.EventContainer:WaitForChild("CheckConsistency") :: RemoteFunction):InvokeServer(Player)
                            if Response.Server then
                                if Response.Client and typeof(Response.Client) == "table" then
                                    Response = CompareClientServer(Response.Client, Response.Server)
                                elseif Response.Client then
                                    Response = {"Client did not return any data."}
                                else
                                    Response = {"Client did not return any data."}
                                end
                            end
                            Output = Response
                        end, function()
                            Output = {}
                        end)
                    end
    
                    --Filter and return the output.
                    local FilteredOutput = {}
                    for _, Message in Output do
                        local Text = Message
                        if type(Message) == "table" then
                            Text = Message.Text
                        end
                        if string.find(string.lower(Text), string.lower(SearchTerm)) then
                            table.insert(FilteredOutput, Message)
                        end
                    end
                    return FilteredOutput
                end
                Window:Show()
            end)
        end
    end,
}