--[[
TheNexusAvenger

Implementation of a command.
--]]
--!strict

local INDENT = "    "

local Workspace = game:GetService("Workspace")
local Localizationservice = game:GetService("LocalizationService")
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VRServie = game:GetService("VRService")

local IncludedCommandUtil = require(script.Parent.Parent:WaitForChild("IncludedCommandUtil"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))



--[[
Attempts to determine the client type.
--]]
local function GetAddressLength(): number
    local MemoryAddressLength = string.match(tostring({}), "x([%dabcdef]+)") :: string
    while true do
        local RemainingAddress = string.match(MemoryAddressLength, "^00000000([%dabcdef]+)")
        if not RemainingAddress then break end
        MemoryAddressLength = RemainingAddress :: string
    end
    return string.len(MemoryAddressLength) * 4
end

--[[
Tries to get a value as a string.
--]]
local function TryGet(Call: () -> (any)): string
    local Worked, Return = pcall(function()
        return tostring(Call())
    end)
    if Worked then
        return Return
    end
    return "Unknown"
end

--[[
Converts an enum to a string.
--]]
local function EnumToString(EnumItem: any): string
    return tostring(string.match(tostring(EnumItem), "[^%.]+%.[^%.]+%.(.+)"))
end



return {
    Keyword = "system",
    Category = "Administrative",
    Description = "Displays information about the system of a client.",
    Arguments = {
        {
            Type = "nexusAdminPlayers",
            Name = "Players",
            Description = "Players to get the system information of.",
        },
    },
    ClientLoad = function(Api: Types.NexusAdminApi)
        --Connect the remote function.
        (Api.EventContainer:WaitForChild("GetSystemInformation") :: RemoteFunction).OnClientInvoke = function()
            local Output = {}

            --Add the initial client information.
            table.insert(Output, "Client version: "..TryGet(Version))
            table.insert(Output, "Client type: "..TryGet(GetAddressLength).."-bit ("..tostring({})..")")
            table.insert(Output, "Client uptime: "..tostring(Workspace.DistributedGameTime).." seconds")
            table.insert(Output, "")

            --Add the localization information.
            table.insert(Output, "Localization:")
            table.insert(Output, INDENT.."RobloxLocaleId: "..TryGet(function() return Localizationservice.RobloxLocaleId end))
            table.insert(Output, INDENT.."SystemLocaleId: "..TryGet(function() return Localizationservice.SystemLocaleId end))
            table.insert(Output, "")

            --Add the input information.
            table.insert(Output, "Hardware:")
            for _, PropertyName in {"KeyboardEnabled", "MouseEnabled", "TouchEnabled", "GamepadEnabled", "VREnabled", "AccelerometerEnabled", "GyroscopeEnabled"} do
                table.insert(Output, INDENT..PropertyName..": "..TryGet(function() return UserInputService[PropertyName] end))
                if PropertyName == "GamepadEnabled" then
                    for _, EnumItem in Enum.UserInputType:GetEnumItems() do
                        local EnumItemName = EnumToString(EnumItem)
                        if not string.find(EnumItemName, "Gamepad") then continue end
                        table.insert(Output, INDENT..INDENT..EnumItemName..": "..TryGet(function() return UserInputService:GetGamepadConnected(EnumItem) end))
                    end
                elseif PropertyName == "VREnabled" then
                    for _, EnumItem in Enum.UserCFrame:GetEnumItems() do
                        local EnumItemName = EnumToString(EnumItem)
                        table.insert(Output, INDENT..INDENT..EnumItemName..": "..TryGet(function() return VRServie:GetUserCFrameEnabled(EnumItem) end))
                    end
                end
            end
            table.insert(Output, "")

            --Add the runtime information.
            table.insert(Output, "Runtime:")
            for _, MethodName in {"IsClient", "IsServer", "IsStudio", "IsEdit", "IsRunMode"} do
                table.insert(Output, INDENT..MethodName..": "..TryGet(function() return RunService[MethodName](RunService) end))
            end

            --Return the output.
            return Output
        end
    end,
    ServerLoad = function(Api: Types.NexusAdminApiServer)
        --Create the remote function.
        local GetSystemInformationRemoteFunction = Instance.new("RemoteFunction")
        GetSystemInformationRemoteFunction.Name = "GetSystemInformation"
        GetSystemInformationRemoteFunction.Parent = Api.EventContainer

        function GetSystemInformationRemoteFunction.OnServerInvoke(Player, TargetPlayer: Player)
            if not TargetPlayer or not TargetPlayer.Parent then
                return {"Disconnected"}
            elseif Api.Authorization:IsPlayerAuthorized(Player, Api.Configuration:GetCommandAdminLevel("Administrative", "system")) then
                local Output = GetSystemInformationRemoteFunction:InvokeClient(TargetPlayer)
                xpcall(function()
                    local Policy = PolicyService:GetPolicyInfoForPlayerAsync(TargetPlayer)
                    table.insert(Output, "")
                    table.insert(Output, "Policy:")
                    for Key, Value in Policy do
                        if typeof(Value) == "table" then
                            table.insert(Output, INDENT..tostring(Key)..":")
                            for SubKey, SubValue in Value do
                                table.insert(Output, INDENT..INDENT..tostring(SubKey)..": "..tostring(SubValue))
                            end
                        else
                            table.insert(Output, INDENT..tostring(Key)..": "..tostring(Value))
                        end
                    end
                end, function(ErrorMessage: string)
                    warn("Failed to fetch policy for "..tostring(TargetPlayer.UserId).." because "..tostring(ErrorMessage))
                end)
                return Output
            else
                return {"Unauthorized"}
            end
        end
    end,
    ClientRun = function(CommandContext: Types.CmdrCommandContext, Players: {Player})
        local Util = IncludedCommandUtil.ForContext(CommandContext)
        local Api = Util:GetApi()
        local ScrollingTextWindow = require(Util.ClientResources:WaitForChild("ScrollingTextWindow")) :: any

        --Display the text window.
        for _, Player in Players do
            task.spawn(function()
                local Output = nil
                local Window = ScrollingTextWindow.new(nil, false)
                Window.Title = "System - "..Player.DisplayName.." ("..Player.Name..")"
                Window.GetTextLines = function(_,SearchTerm,ForceRefresh)
                    --Get the output.
                    if not Output or ForceRefresh then
                        Output = (Api.EventContainer:WaitForChild("GetSystemInformation") :: RemoteFunction):InvokeServer(Player)
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